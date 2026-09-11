<#
.SYNOPSIS
  Weekly / on-demand MCP vs native usage audit from Cursor agent-transcripts.
.DESCRIPTION
  Compares last 7 days vs previous 7 days (or custom). Emits ALERT when
  replacement shares fall below thresholds. Project-agnostic if -TranscriptsRoot set.
.PARAMETER TranscriptsRoot
  Path to agent-transcripts (default: UT25_85 Cursor project transcripts).
.PARAMETER OutDir
  Where to write json/txt report.
.PARAMETER Days
  Length of "recent" window (default 7). Baseline = previous N days.
.PARAMETER FailOnAlert
  Exit 1 if any threshold ALERT.
#>
param(
    [string]$TranscriptsRoot = 'C:\Users\Admin\.cursor\projects\c-Cursor-UT25-85\agent-transcripts',
    [string]$OutDir = 'C:\Cursor\UT25_85\_ai_agent',
    [int]$Days = 7,
    [switch]$FailOnAlert,
    [hashtable]$Thresholds = @{
        mcpSharePct      = 40
        readMcpSharePct  = 30
        grepMcpSharePct  = 40
        shellMcpSharePct = 15
        maxNativeGrep    = 250
    }
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$now = Get-Date
$pBEnd = $now.Date.AddDays(1)          # exclusive end = tomorrow
$pBStart = $pBEnd.AddDays(-$Days)
$pAEnd = $pBStart
$pAStart = $pAEnd.AddDays(-$Days)

function New-Bucket {
    return [ordered]@{
        sessions = 0; bytes = 0; toolCalls = 0
        byTool = @{}; mcp = @{}; native = @{ Read = 0; Grep = 0; Shell = 0; Glob = 0; Edit = 0; Other = 0 }
        repl = @{
            read_n = 0; read_ctx = 0
            grep_n = 0; grep_ctx = 0; grep_atlas = 0; grep_ci = 0
            shell_n = 0; shell_ctx = 0
        }
        kb = @{ consult = 0; reuse = 0; stored = 0; mcp_tried = 0 }
    }
}

$mcpKnown = @{
    'lean-ctx' = @('ctx_read','ctx_search','ctx_shell','ctx_tree','ctx_edit','ctx_session','ctx_knowledge','ctx_overview','ctx_multi_read')
    'bsl-atlas' = @('search_function','read_function','code_grep','codesearch','metadatasearch','get_object_details','verify_call','verify_field','get_form_info','get_skd_info','search_code_filtered','helpsearch','stats','repomap','get_module_functions','triggers_on_write','reindex_changed')
    'code-index' = @('grep_code','grep_body','grep_text','search_function','get_function','get_callers','get_callees','search_text','find_symbol','list_files','get_file_summary')
    'naparnik' = @('check_1c_code','review_1c_code','config_help','its_help','fetch_its','onec_help','explain_1c_syntax','ask_1c_ai')
    'syntax-helper' = @('list_object_members','get_syntax_info','find_1c_help','get_quick_reference','search_by_context')
    'mcp-meta' = @('CallMcpTool','GetMcpTools','FetchMcpResource')
    'litecode' = @('search_metadata')
    'mcp-1c' = @('execute_query','validate_query','get_metadata_tree','get_object_structure','get_form_structure','bsl_syntax_help')
    'v8std' = @('v8std_search','v8std_get_page','v8std_explain_snippet','v8std_explain_diagnostics')
}

$toolToSrv = @{}
foreach ($srv in $mcpKnown.Keys) {
    foreach ($t in $mcpKnown[$srv]) {
        if (-not $toolToSrv.ContainsKey($t)) { $toolToSrv[$t] = $srv }
    }
}

function Classify([string]$name, $b) {
    if ([string]::IsNullOrWhiteSpace($name)) { return }
    $b.toolCalls++
    if (-not $b.byTool.ContainsKey($name)) { $b.byTool[$name] = 0 }
    $b.byTool[$name]++

    if ($toolToSrv.ContainsKey($name)) {
        $srv = $toolToSrv[$name]
        if (-not $b.mcp.ContainsKey($srv)) { $b.mcp[$srv] = 0 }
        $b.mcp[$srv]++
    } else {
        switch -Regex ($name) {
            '^Read$' { $b.native.Read++ }
            '^Grep$' { $b.native.Grep++ }
            '^Shell$' { $b.native.Shell++ }
            '^Glob$' { $b.native.Glob++ }
            '^(StrReplace|Write|Delete|EditNotebook)$' { $b.native.Edit++ }
            default { $b.native.Other++ }
        }
    }

    switch -Regex ($name) {
        '^Read$' { $b.repl.read_n++ }
        '^ctx_read$' { $b.repl.read_ctx++ }
        '^Grep$' { $b.repl.grep_n++ }
        '^ctx_search$' { $b.repl.grep_ctx++ }
        '^(code_grep|codesearch|search_code_filtered)$' { $b.repl.grep_atlas++ }
        '^(grep_code|grep_body|grep_text)$' { $b.repl.grep_ci++ }
        '^Shell$' { $b.repl.shell_n++ }
        '^ctx_shell$' { $b.repl.shell_ctx++ }
    }
}

function Ingest-File($path, $b) {
    $b.sessions++
    $b.bytes += (Get-Item -LiteralPath $path).Length
    $reader = [System.IO.StreamReader]::new($path, [System.Text.Encoding]::UTF8)
    try {
        while ($null -ne ($line = $reader.ReadLine())) {
            if ($line.Length -lt 20) { continue }
            if ($line -match 'KB:\s*') { $b.kb.consult++ }
            if ($line -match 'REUSE:\s*') { $b.kb.reuse++ }
            if ($line -match 'STORED:\s*') { $b.kb.stored++ }
            if ($line -match 'MCP tried:|fallback because') { $b.kb.mcp_tried++ }

            foreach ($m in [regex]::Matches($line, '"type"\s*:\s*"tool_use"[^\{]{0,80}"name"\s*:\s*"([^"]+)"')) {
                Classify $m.Groups[1].Value $b
            }
            foreach ($m in [regex]::Matches($line, '"name"\s*:\s*"([^"]+)"[^\}]{0,120}"type"\s*:\s*"tool_use"')) {
                Classify $m.Groups[1].Value $b
            }
            if ($line -match 'CallMcpTool' -or $line -match '"toolName"') {
                foreach ($m in [regex]::Matches($line, '"toolName"\s*:\s*"([^"]+)"')) {
                    $tn = $m.Groups[1].Value
                    if ($tn -notin @('CallMcpTool','GetMcpTools','FetchMcpResource')) {
                        Classify $tn $b
                    }
                }
            }
        }
    } finally { $reader.Close() }
}

function Pct($part, $whole) {
    if ($whole -le 0) { return 0 }
    return [math]::Round(100.0 * $part / $whole, 1)
}

function Summarize($b) {
    $mcpSum = 0; foreach ($k in $b.mcp.Keys) { $mcpSum += $b.mcp[$k] }
    $nativeSum = 0; foreach ($k in $b.native.Keys) { $nativeSum += $b.native[$k] }
    $readT = $b.repl.read_n + $b.repl.read_ctx
    $grepT = $b.repl.grep_n + $b.repl.grep_ctx + $b.repl.grep_atlas + $b.repl.grep_ci
    $shellT = $b.repl.shell_n + $b.repl.shell_ctx
    return [ordered]@{
        sessions = $b.sessions
        toolCalls = $b.toolCalls
        bytesMB = [math]::Round($b.bytes / 1MB, 2)
        mcpTotal = $mcpSum
        nativeTotal = $nativeSum
        mcpSharePct = Pct $mcpSum ($mcpSum + $nativeSum)
        readMcpSharePct = Pct $b.repl.read_ctx $readT
        grepMcpSharePct = Pct ($b.repl.grep_ctx + $b.repl.grep_atlas + $b.repl.grep_ci) $grepT
        shellMcpSharePct = Pct $b.repl.shell_ctx $shellT
        nativeGrep = $b.repl.grep_n
        nativeRead = $b.repl.read_n
        ctx_read = $b.repl.read_ctx
        ctx_search = $b.repl.grep_ctx
        ctx_shell = $b.repl.shell_ctx
        atlas_grep = $b.repl.grep_atlas
        mcp = $b.mcp
        kb = $b.kb
        repl = $b.repl
    }
}

$A = New-Bucket
$B = New-Bucket

$files = Get-ChildItem -Path $TranscriptsRoot -Recurse -Filter '*.jsonl' -File -ErrorAction SilentlyContinue
foreach ($f in $files) {
    $mt = $f.LastWriteTime
    if ($mt -ge $pAStart -and $mt -lt $pAEnd) { Ingest-File $f.FullName $A }
    elseif ($mt -ge $pBStart -and $mt -lt $pBEnd) { Ingest-File $f.FullName $B }
}

$sa = Summarize $A
$sb = Summarize $B

$alerts = New-Object System.Collections.Generic.List[string]
if ($sb.mcpSharePct -lt $Thresholds.mcpSharePct) {
    [void]$alerts.Add("ALERT mcpSharePct=$($sb.mcpSharePct) < $($Thresholds.mcpSharePct)")
}
if ($sb.readMcpSharePct -lt $Thresholds.readMcpSharePct) {
    [void]$alerts.Add("ALERT readMcpSharePct=$($sb.readMcpSharePct) < $($Thresholds.readMcpSharePct)")
}
if ($sb.grepMcpSharePct -lt $Thresholds.grepMcpSharePct) {
    [void]$alerts.Add("ALERT grepMcpSharePct=$($sb.grepMcpSharePct) < $($Thresholds.grepMcpSharePct)")
}
if ($sb.shellMcpSharePct -lt $Thresholds.shellMcpSharePct) {
    [void]$alerts.Add("ALERT shellMcpSharePct=$($sb.shellMcpSharePct) < $($Thresholds.shellMcpSharePct)")
}
if ($sb.nativeGrep -gt $Thresholds.maxNativeGrep) {
    [void]$alerts.Add("ALERT nativeGrep=$($sb.nativeGrep) > $($Thresholds.maxNativeGrep)")
}
if ($sb.kb.mcp_tried -eq 0 -and ($sb.nativeGrep + $sb.nativeRead) -gt 50) {
    [void]$alerts.Add('ALERT no MCP-tried lines while heavy native Read/Grep')
}
if ($sb.kb.consult -eq 0 -and ($sb.nativeGrep + $sb.nativeRead) -gt 50) {
    [void]$alerts.Add('WARN KB: proof missing in recent implement-heavy window')
}

$result = [ordered]@{
    generatedAt = $now.ToString('s')
    windowDays = $Days
    baseline = @{ label = "$($pAStart.ToString('yyyy-MM-dd')) .. $($pAEnd.AddDays(-1).ToString('yyyy-MM-dd'))"; summary = $sa }
    recent = @{ label = "$($pBStart.ToString('yyyy-MM-dd')) .. $($pBEnd.AddDays(-1).ToString('yyyy-MM-dd'))"; summary = $sb }
    thresholds = $Thresholds
    alerts = @($alerts)
    status = if ($alerts.Count -eq 0) { 'OK' } elseif ($alerts -match '^ALERT') { 'ALERT' } else { 'WARN' }
}

$stamp = $now.ToString('yyyyMMdd-HHmm')
$jsonPath = Join-Path $OutDir "mcp-usage-audit-$stamp.json"
$txtPath = Join-Path $OutDir "mcp-usage-audit-$stamp.txt"
$latestJson = Join-Path $OutDir 'mcp-usage-audit-latest.json'
$latestTxt = Join-Path $OutDir 'mcp-usage-audit-latest.txt'

$result | ConvertTo-Json -Depth 8 | Set-Content -Path $jsonPath -Encoding UTF8
Copy-Item $jsonPath $latestJson -Force

$lines = @(
    '=== MCP USAGE AUDIT ==='
    "Generated: $($result.generatedAt)  status=$($result.status)"
    "Baseline: $($result.baseline.label)"
    "  sessions=$($sa.sessions) tools=$($sa.toolCalls) mcpShare=$($sa.mcpSharePct)% readMcp=$($sa.readMcpSharePct)% grepMcp=$($sa.grepMcpSharePct)% shellMcp=$($sa.shellMcpSharePct)% nativeGrep=$($sa.nativeGrep)"
    "Recent:   $($result.recent.label)"
    "  sessions=$($sb.sessions) tools=$($sb.toolCalls) mcpShare=$($sb.mcpSharePct)% readMcp=$($sb.readMcpSharePct)% grepMcp=$($sb.grepMcpSharePct)% shellMcp=$($sb.shellMcpSharePct)% nativeGrep=$($sb.nativeGrep)"
    "KB recent: consult=$($sb.kb.consult) reuse=$($sb.kb.reuse) stored=$($sb.kb.stored) mcp_tried=$($sb.kb.mcp_tried)"
    'Thresholds: ' + (($Thresholds.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ')
    '---'
)
if ($alerts.Count -eq 0) { $lines += 'No alerts.' }
else { foreach ($a in $alerts) { $lines += $a } }
$lines += ''
$lines += 'Playbook on ALERT: lesson process-mcp-io-discipline; prefer atlas -> read_function -> ctx_read; ban silent Grep on *.bsl.'

$text = $lines -join "`r`n"
Set-Content -Path $txtPath -Value $text -Encoding UTF8
Copy-Item $txtPath $latestTxt -Force

Write-Output $text
Write-Output "JSON=$jsonPath"

if ($FailOnAlert -and ($result.status -eq 'ALERT')) { exit 1 }
