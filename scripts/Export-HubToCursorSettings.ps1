<#
.SYNOPSIS
  Push Hub agent-pack + project template updates into a local CursorSettings git clone.
.PARAMETER Repo
  Path to CursorSettings repo (default: %TEMP%\CursorSettings).
.PARAMETER TemplateProject
  Source for non-Hub template rules/docs (default: C:\Cursor\UT25_85).
#>
param(
    [string]$Repo = (Join-Path $env:TEMP "CursorSettings"),
    [string]$TemplateProject = "C:\Cursor\UT25_85"
)

$ErrorActionPreference = "Stop"
$Hub = "C:\1c-shared-patterns\cursor-addons"
$HubRulesDir = Join-Path $Hub "rules-shared"
if (-not (Test-Path -LiteralPath $Repo)) {
    throw "Clone CursorSettings first: git clone https://github.com/ZiborovaDaria/CursorSettings.git `"$Repo`""
}
if (-not (Test-Path -LiteralPath $TemplateProject)) {
    throw "Missing template project: $TemplateProject"
}

function Copy-Tracked {
    param([string]$Src, [string]$Dst)
    if (-not (Test-Path -LiteralPath $Src)) { throw "Missing source: $Src" }
    $dir = Split-Path -Parent $Dst
    if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Copy-Item -Force -LiteralPath $Src -Destination $Dst
    Write-Host "OK $Dst"
}

Write-Host "Repo=$Repo"
Write-Host "Template=$TemplateProject"

# --- Hub shared rules (SoT): ALL *.mdc ---
$HubRuleNames = @()
Get-ChildItem -LiteralPath $HubRulesDir -Filter "*.mdc" -File | ForEach-Object {
    $HubRuleNames += $_.Name
    $dst = Join-Path $Repo ".cursor\rules\$($_.Name)"
    if ($_.Name -eq "hub-gate.mdc") {
        $body = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
        if ($body -notmatch "DO NOT EDIT") {
            $body = $body -replace "(?s)(---\r?\nalwaysApply: true\r?\n---\r?\n)", "`$1`r`n<!-- DO NOT EDIT - synced from C:\1c-shared-patterns\cursor-addons\rules-shared\hub-gate.mdc -->`r`n`r`n"
        }
        Set-Content -LiteralPath $dst -Value $body -Encoding UTF8 -NoNewline
        Write-Host "OK $dst"
    } else {
        Copy-Tracked -Src $_.FullName -Dst $dst
    }
}

# --- Hub project root ---
foreach ($f in @("AGENTS.md", "memory.md", "LLM-RULES.md", "USER-RULES.md", ".cursorrules")) {
    Copy-Tracked -Src (Join-Path $Hub "project-root\$f") -Dst (Join-Path $Repo $f)
}

# --- Hub global skills export ---
foreach ($sk in @("consult-1c-shared-lessons", "reuse-1c-shared-patterns", "error-learning-1c", "1c-ssl-patterns")) {
    $dst = Join-Path $Repo ".cursor\export\global-skills\$sk\SKILL.md"
    Copy-Tracked -Src (Join-Path $Hub "skills\$sk\SKILL.md") -Dst $dst
}

$howSearch = "C:\1c-shared-patterns\playbooks\agent-lessons\HOW-SEARCH.md"
if (Test-Path -LiteralPath $howSearch) {
    Copy-Tracked -Src $howSearch -Dst (Join-Path $Repo "docs\HUB_KB_SEARCH.md")
}

# --- Portable skills from template ---
foreach ($sk in @("1c-debug-mcp", "v8-runner")) {
    $srcSkill = Join-Path $TemplateProject ".cursor\skills\$sk\SKILL.md"
    if (Test-Path -LiteralPath $srcSkill) {
        Copy-Tracked -Src $srcSkill -Dst (Join-Path $Repo ".cursor\export\global-skills\$sk\SKILL.md")
        Copy-Tracked -Src $srcSkill -Dst (Join-Path $Repo ".cursor\skills\$sk\SKILL.md")
    }
}

# --- MCP audit / install scripts from Hub ---
$scriptsDst = Join-Path $Repo "scripts"
New-Item -ItemType Directory -Force -Path $scriptsDst | Out-Null
foreach ($script in @(
        "Invoke-McpUsageAudit.ps1",
        "Invoke-McpUsageAudit-Project.ps1",
        "Sync-1cAgentPack.ps1",
        "Export-HubToCursorSettings.ps1",
        "Check-1cAgentDrift.ps1",
        "sync-manifest.json"
    )) {
    $src = Join-Path $Hub "install\$script"
    if (Test-Path -LiteralPath $src) {
        Copy-Tracked -Src $src -Dst (Join-Path $scriptsDst $script)
    }
}

# --- Template rules from UT (exclude project-specific + Hub SoT) ---
$SkipRules = @(
    "01-ut-project-context.mdc",
    "project-esti-context-agent.mdc",
    "project-esti-error-learning-agent.mdc",
    "project-esti-mcp-router-agent.mdc",
    "project-esti-orchestrator-bridge-agent.mdc",
    "project-esti-single-1c-launch-agent.mdc",
    "project-esti-tooling-playbooks-agent.mdc",
    "project-esti-cfe-delivery-agent.mdc",
    "project-esti-lurv-agent.mdc",
    "24-always-mcp-tool-router.mdc",
    "26-always-no-webfetch.mdc"
) + $HubRuleNames

$tplRules = Join-Path $TemplateProject ".cursor\rules"
foreach ($rule in Get-ChildItem -LiteralPath $tplRules -Filter "*.mdc" -File) {
    if ($SkipRules -contains $rule.Name) { continue }
    Copy-Tracked -Src $rule.FullName -Dst (Join-Path $Repo ".cursor\rules\$($rule.Name)")
}

# --- Template .cursor docs ---
foreach ($doc in @("MCP_ROUTER.md", "MCP_SETUP.md", "MCP_PLAYBOOKS.md", "RULES_INDEX.md", "README.md", "INSTALL_OTHER_DEVICE.md")) {
    $src = Join-Path $TemplateProject ".cursor\$doc"
    if (Test-Path -LiteralPath $src) {
        Copy-Tracked -Src $src -Dst (Join-Path $Repo ".cursor\$doc")
    }
}

$installAll = "C:\Cursor\ESTI\.cursor\INSTALL_ALL_PROJECTS.md"
if (Test-Path -LiteralPath $installAll) {
    Copy-Tracked -Src $installAll -Dst (Join-Path $Repo ".cursor\INSTALL_ALL_PROJECTS.md")
}

# --- Commands: UT + ESTI ---
$dstCmd = Join-Path $Repo ".cursor\commands"
New-Item -ItemType Directory -Force -Path $dstCmd | Out-Null
foreach ($srcDir in @((Join-Path $TemplateProject ".cursor\commands"), "C:\Cursor\ESTI\.cursor\commands")) {
    if (-not (Test-Path -LiteralPath $srcDir)) { continue }
    Get-ChildItem -LiteralPath $srcDir -File | ForEach-Object {
        Copy-Tracked -Src $_.FullName -Dst (Join-Path $dstCmd $_.Name)
    }
}

# --- ESTI project rules + LURV API doc ---
foreach ($r in @(
        "project-esti-cfe-delivery-agent.mdc",
        "project-esti-lurv-agent.mdc",
        "project-esti-context-agent.mdc",
        "project-esti-error-learning-agent.mdc",
        "project-esti-mcp-router-agent.mdc",
        "project-esti-orchestrator-bridge-agent.mdc",
        "project-esti-single-1c-launch-agent.mdc",
        "project-esti-tooling-playbooks-agent.mdc"
    )) {
    $src = "C:\Cursor\ESTI\.cursor\rules\$r"
    if (Test-Path -LiteralPath $src) {
        Copy-Tracked -Src $src -Dst (Join-Path $Repo ".cursor\rules\$r")
    }
}
Get-ChildItem "C:\Cursor\ESTI\Extent" -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "LURV|ЛУРВ" } |
    Select-Object -First 1 |
    ForEach-Object {
        $postSrc = Join-Path $_.FullName "POST-lurv.md"
        if (Test-Path -LiteralPath $postSrc) {
            Copy-Tracked -Src $postSrc -Dst (Join-Path $Repo "docs\ESTI_POST_lurv.md")
        }
    }

# --- Contractors / Extent templates ---
$ctrReadme = "C:\Cursor\UT25_85\memory-bank\contractors\README.md"
if (Test-Path -LiteralPath $ctrReadme) {
    Copy-Tracked -Src $ctrReadme -Dst (Join-Path $Repo "memory-bank\contractors\README.md")
}
$extReadme = "C:\Cursor\UT25_85\Extent\README.md"
if (Test-Path -LiteralPath $extReadme) {
    Copy-Tracked -Src $extReadme -Dst (Join-Path $Repo "templates\extent-contractors\README.md")
}

# --- Retire obsolete stubs ---
$legacyDir = Join-Path $Repo ".cursor\rules\_legacy"
New-Item -ItemType Directory -Force -Path $legacyDir | Out-Null
foreach ($stub in @("24-always-mcp-tool-router.mdc", "26-always-no-webfetch.mdc")) {
    $active = Join-Path $Repo ".cursor\rules\$stub"
    if (Test-Path -LiteralPath $active) {
        Move-Item -Force -LiteralPath $active -Destination (Join-Path $legacyDir ($stub + ".off"))
        Write-Host "MOVED $stub -> _legacy"
    }
}

Write-Host "DONE. Next:"
Write-Host "  cd `"$Repo`""
Write-Host "  git add -A"
Write-Host '  git commit -m "sync: Hub agent pack + UT template rules"'
Write-Host "  git push"
