#Requires -Version 5.1
<#
.SYNOPSIS
  Установка настроек Cursor/агента ЭСТИ на новом ПК из репозитория.

.DESCRIPTION
  Копирует bundled global-rules, global-skills (все 1С-навыки), scripts, templates,
  supercode modes в ~/.cursor/ и workspace.

.PARAMETER Profile
  POWER (Atlas+litecode) или LITE (только litecode).

.PARAMETER SkipMcp
  Не трогать .cursor/mcp.json (если уже настроен).

.EXAMPLE
  powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1
  powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile LITE
#>
[CmdletBinding()]
param(
    [ValidateSet('POWER', 'LITE')]
    [string]$Profile = 'POWER',
    [switch]$SkipMcp
)

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$exportRoot = Join-Path $repoRoot '.cursor\export'
$userCursor = Join-Path $env:USERPROFILE '.cursor'

Write-Host "=== Install ESTI Cursor settings ===" -ForegroundColor Cyan
Write-Host "Repo: $repoRoot | Profile: $Profile"

if (-not (Test-Path $exportRoot)) {
    throw "Missing .cursor/export — git clone/pull CursorSettings or ESTI"
}

# 1. Global rules -> ~/.cursor/rules
$rulesSrc = Join-Path $exportRoot 'global-rules'
$userRules = Join-Path $userCursor 'rules'
New-Item -ItemType Directory -Path $userRules -Force | Out-Null
Copy-Item (Join-Path $rulesSrc '*.mdc') $userRules -Force
Write-Host "rules: $((Get-ChildItem $rulesSrc -Filter *.mdc).Count) -> $userRules"

# 2. Global skills (all) -> ~/.cursor/skills
$skillsSrc = Join-Path $exportRoot 'global-skills'
$userSkills = Join-Path $userCursor 'skills'
if (Test-Path $skillsSrc) {
    New-Item -ItemType Directory -Path $userSkills -Force | Out-Null
    $count = 0
    Get-ChildItem $skillsSrc -Directory | ForEach-Object {
        $dst = Join-Path $userSkills $_.Name
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item $_.FullName $dst -Recurse -Force
        $count++
    }
    Write-Host "skills: $count -> $userSkills"
}

# 3. Global scripts -> ~/.cursor/scripts
$scriptsSrc = Join-Path $exportRoot 'global-scripts'
$userScripts = Join-Path $userCursor 'scripts'
if (Test-Path $scriptsSrc) {
    New-Item -ItemType Directory -Path $userScripts -Force | Out-Null
    Copy-Item (Join-Path $scriptsSrc '*') $userScripts -Force
    Write-Host "scripts -> $userScripts (sync-global-rules.ps1, sync-project-mcp.ps1)"
}

# 4. Templates -> ~/.cursor/templates
$tplSrc = Join-Path $exportRoot 'global-templates'
if (Test-Path $tplSrc) {
    $userTpl = Join-Path $userCursor 'templates'
    New-Item -ItemType Directory -Path $userTpl -Force | Out-Null
    Copy-Item (Join-Path $tplSrc '*') $userTpl -Force -Recurse
    Write-Host "templates -> $userTpl"
}

# 5. Supercode memory-bank modes -> workspace .supercode
$scSrc = Join-Path $exportRoot 'supercode'
$scDst = Join-Path $repoRoot '.supercode'
if (Test-Path $scSrc) {
    if (Test-Path $scDst) { Remove-Item $scDst -Recurse -Force }
    Copy-Item $scSrc $scDst -Recurse -Force
    Write-Host "supercode -> $scDst"
    Write-Host "  Установите расширение: supercode.supercode-sh (см. .vscode/extensions.json)"
}

# 6. MCP profile
if (-not $SkipMcp) {
    $profileFile = if ($Profile -eq 'LITE') {
        Join-Path $repoRoot '.cursor\mcp.profile.lite.json'
    } else {
        Join-Path $repoRoot '.cursor\mcp.profile.power.json'
    }
    $mcpTarget = Join-Path $repoRoot '.cursor\mcp.json'
    if (Test-Path $profileFile) {
        Copy-Item $profileFile $mcpTarget -Force
        Write-Host "mcp.json <- $([IO.Path]::GetFileName($profileFile))"
    }
}

# 7. Skill deps
$depsScript = Join-Path $repoRoot '.cursor\scripts\Install-ESTI-SkillDeps.ps1'
if (Test-Path $depsScript) { & $depsScript }

# 8. Sync global-* into project
$syncScript = Join-Path $userScripts 'sync-global-rules.ps1'
if (Test-Path $syncScript) {
    & $syncScript -Projects $repoRoot
}

Write-Host ""
Write-Host "=== Вручную ===" -ForegroundColor Yellow
Write-Host "1. Cursor Settings -> Rules: USER-RULES.md (caveman)"
Write-Host "2. .dev.env.example -> .dev.env"
Write-Host "3. infobasesettings.md локально"
Write-Host "4. Extensions: supercode.supercode-sh"
Write-Host "5. MCP Reload + /doctor"
Write-Host "Done." -ForegroundColor Green
