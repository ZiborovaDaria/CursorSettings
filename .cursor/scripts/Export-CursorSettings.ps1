#Requires -Version 5.1
<#
.SYNOPSIS
  Update .cursor/export from ~/.cursor and workspace (before git push).

.DESCRIPTION
  Exports: global-rules, global-skills, agent-skills, skills-cursor,
  global-commands, global-agents, mcp profiles, scripts, templates, supercode.
  Syncs commands to shared-bundle.

.EXAMPLE
  powershell -File .cursor\scripts\Export-CursorSettings.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$export = Join-Path $repoRoot '.cursor\export'
$userCursor = Join-Path $env:USERPROFILE '.cursor'
$userAgents = Join-Path $env:USERPROFILE '.agents'

Write-Host '=== Export Cursor settings ===' -ForegroundColor Cyan

if (-not (Test-Path $export)) {
    New-Item -ItemType Directory -Path $export -Force | Out-Null
}

function Export-Tree {
    param(
        [string]$Src,
        [string]$Dst
    )
    if (-not (Test-Path $Src)) { return 0 }
    if (Test-Path $Dst) { Remove-Item $Dst -Recurse -Force }
    New-Item -ItemType Directory -Path $Dst -Force | Out-Null
    $null = robocopy $Src $Dst /E /NFL /NDL /NJH /NJS /nc /ns /np /XD node_modules __pycache__ .git 2>&1
    return (Get-ChildItem $Dst -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
}

# Global rules
$rulesDst = Join-Path $export 'global-rules'
New-Item -ItemType Directory -Path $rulesDst -Force | Out-Null
Copy-Item (Join-Path $userCursor 'rules\*.mdc') $rulesDst -Force -ErrorAction SilentlyContinue
$ruleCount = (Get-ChildItem $rulesDst -Filter '*.mdc' -ErrorAction SilentlyContinue).Count
Write-Host "rules: $ruleCount"

# Global skills (~/.cursor/skills)
$skillsSrc = Join-Path $userCursor 'skills'
$skillsDst = Join-Path $export 'global-skills'
$n = Export-Tree $skillsSrc $skillsDst
$skillDirs = (Get-ChildItem $skillsDst -Directory -ErrorAction SilentlyContinue).Count
Write-Host "global-skills: $n files, $skillDirs skills"

# Agent skills (~/.agents/skills)
$agentSkillsSrc = Join-Path $userAgents 'skills'
$agentSkillsDst = Join-Path $export 'agent-skills'
$n = Export-Tree $agentSkillsSrc $agentSkillsDst
Write-Host "agent-skills: $n files"

# Cursor skills-cursor
$scSrc = Join-Path $userCursor 'skills-cursor'
$scDst = Join-Path $export 'global-skills-cursor'
$n = Export-Tree $scSrc $scDst
if ($n -gt 0) { Write-Host "skills-cursor: $n files" }

# Global agents (subagents 1c-ext-*)
$agentsSrc = Join-Path $userCursor 'agents'
$agentsDst = Join-Path $export 'global-agents'
if (Test-Path $agentsSrc) {
    if (Test-Path $agentsDst) { Remove-Item $agentsDst -Recurse -Force }
    New-Item -ItemType Directory -Path $agentsDst -Force | Out-Null
    Copy-Item (Join-Path $agentsSrc '*.md') $agentsDst -Force
    $agentCount = (Get-ChildItem $agentsDst -Filter '*.md').Count
    Write-Host "global-agents: $agentCount"
} else {
    Write-Warning 'No ~/.cursor/agents - skip'
}

# Global commands (from ESTI workspace)
$cmdSrc = Join-Path $repoRoot '.cursor\commands'
$cmdDst = Join-Path $export 'global-commands'
if (Test-Path $cmdSrc) {
    if (Test-Path $cmdDst) { Remove-Item $cmdDst -Recurse -Force }
    New-Item -ItemType Directory -Path $cmdDst -Force | Out-Null
    Copy-Item (Join-Path $cmdSrc '*') $cmdDst -Force
    $cmdCount = (Get-ChildItem $cmdDst -File).Count
    Write-Host "global-commands: $cmdCount"

    $bundleCmd = Join-Path $repoRoot '.cursor\shared-bundle\commands'
    New-Item -ItemType Directory -Path $bundleCmd -Force | Out-Null
    Get-ChildItem $cmdDst -File | Where-Object { $_.Extension -in '.md', '.py' } | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $bundleCmd $_.Name) -Force
    }
    Write-Host 'shared-bundle/commands: synced'
}

# MCP profiles (no secrets)
$mcpDst = Join-Path $export 'mcp'
New-Item -ItemType Directory -Path $mcpDst -Force | Out-Null
foreach ($name in @('mcp.profile.power.json', 'mcp.profile.lite.json', 'mcp.local.json.example')) {
    $src = Join-Path $repoRoot ".cursor\$name"
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $mcpDst $name) -Force
    }
}
$mcpReadmeLines = @(
    '# MCP profiles (CursorSettings)',
    '',
    '- mcp.profile.power.json - POWER: Atlas + litecode',
    '- mcp.profile.lite.json - LITE: litecode + code-index',
    '- mcp.local.json.example - local secrets template',
    '',
    'Install: Install-ESTI-OnNewDevice.ps1 -Profile POWER',
    '',
    'Active .cursor/mcp.json is not committed.',
    'See MCP_ROUTER_ESTI.md, MCP_LITE_DEVICE.md.'
)
$mcpReadme = ($mcpReadmeLines -join [Environment]::NewLine) + [Environment]::NewLine
[IO.File]::WriteAllText((Join-Path $mcpDst 'README.md'), $mcpReadme, [Text.UTF8Encoding]::new($false))
Write-Host 'mcp profiles: OK'

# Global scripts
$scriptsDst = Join-Path $export 'global-scripts'
New-Item -ItemType Directory -Path $scriptsDst -Force | Out-Null
Copy-Item (Join-Path $userCursor 'scripts\*') $scriptsDst -Force -ErrorAction SilentlyContinue
$scriptCount = (Get-ChildItem $scriptsDst -File -ErrorAction SilentlyContinue).Count
Write-Host "scripts: $scriptCount"

# Templates
$tplSrc = Join-Path $userCursor 'templates'
if (Test-Path $tplSrc) {
    $tplDst = Join-Path $export 'global-templates'
    $null = Export-Tree $tplSrc $tplDst
    Write-Host 'templates: OK'
}

# Supercode (from workspace)
$scWs = Join-Path $repoRoot '.supercode'
if (Test-Path $scWs) {
    $scExp = Join-Path $export 'supercode'
    if (Test-Path $scExp) { Remove-Item $scExp -Recurse -Force }
    Copy-Item $scWs $scExp -Recurse -Force
    Write-Host 'supercode: OK'
}

Write-Host ''
Write-Host 'Done. Commit .cursor/export and .cursor/shared-bundle/commands, then git push.' -ForegroundColor Green
