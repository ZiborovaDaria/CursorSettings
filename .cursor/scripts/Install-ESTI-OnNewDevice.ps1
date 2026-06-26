#Requires -Version 5.1
<#
.SYNOPSIS
  Установка настроек Cursor/агента ЭСТИ на новом ПК из репозитория.

.DESCRIPTION
  Копирует bundled global-rules и global-skills в ~/.cursor/,
  настраивает mcp.json по профилю, ставит deps навыков.

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
$globalRulesSrc = Join-Path $exportRoot 'global-rules'
$globalSkillsSrc = Join-Path $exportRoot 'global-skills'
$userCursor = Join-Path $env:USERPROFILE '.cursor'
$userRules = Join-Path $userCursor 'rules'
$userSkills = Join-Path $userCursor 'skills'

Write-Host "=== Install ESTI Cursor settings ===" -ForegroundColor Cyan
Write-Host "Repo: $repoRoot"
Write-Host "Profile: $Profile"

# 1. Global rules
if (-not (Test-Path $globalRulesSrc)) {
    throw "Missing export: $globalRulesSrc — run git pull"
}
New-Item -ItemType Directory -Path $userRules -Force | Out-Null
Copy-Item (Join-Path $globalRulesSrc '*.mdc') $userRules -Force
Write-Host "Global rules -> $userRules ($((Get-ChildItem $globalRulesSrc -Filter *.mdc).Count) files)"

# 2. Global skills
if (Test-Path $globalSkillsSrc) {
    New-Item -ItemType Directory -Path $userSkills -Force | Out-Null
    Get-ChildItem $globalSkillsSrc -Directory | ForEach-Object {
        $dst = Join-Path $userSkills $_.Name
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item $_.FullName $dst -Recurse -Force
        Write-Host "  skill: $($_.Name)"
    }
}

# 3. MCP profile
if (-not $SkipMcp) {
    $profileFile = if ($Profile -eq 'LITE') {
        Join-Path $repoRoot '.cursor\mcp.profile.lite.json'
    } else {
        Join-Path $repoRoot '.cursor\mcp.profile.power.json'
    }
    $mcpTarget = Join-Path $repoRoot '.cursor\mcp.json'
    if (-not (Test-Path $profileFile)) {
        Write-Warning "Profile template not found: $profileFile"
    } else {
        Copy-Item $profileFile $mcpTarget -Force
        Write-Host "mcp.json <- $([IO.Path]::GetFileName($profileFile))"
        Write-Host "  -> Cursor: Settings -> MCP -> Reload"
    }
}

# 4. device_profile hint
$deviceFile = Join-Path $repoRoot '.cursor\rules\00-esti-device-profile.mdc'
if (Test-Path $deviceFile) {
    $content = Get-Content $deviceFile -Raw
    if ($content -notmatch "device_profile:\s*$Profile") {
        Write-Warning "Проверьте device_profile в 00-esti-device-profile.mdc (ожидается $Profile)"
    }
}

# 5. Skill deps (transcribe, md-to-docx)
$depsScript = Join-Path $repoRoot '.cursor\scripts\Install-ESTI-SkillDeps.ps1'
if (Test-Path $depsScript) {
    Write-Host "Skill dependencies..."
    & $depsScript
}

# 6. Sync global rules into ESTI project copies
$syncScript = Join-Path $env:USERPROFILE '.cursor\scripts\sync-global-rules.ps1'
if (Test-Path $syncScript) {
    Write-Host "Sync global-* rules into projects..."
    & $syncScript -Projects $repoRoot
} else {
    Write-Warning "sync-global-rules.ps1 not found in ~/.cursor/scripts — global-* в проекте могут отставать"
}

Write-Host ""
Write-Host "=== Вручную ===" -ForegroundColor Yellow
Write-Host "1. Cursor Settings -> Rules: добавить исключение из USER-RULES.md (корень репо)"
Write-Host "2. Скопировать .dev.env.example -> .dev.env, поправить пути/пароли"
Write-Host "3. infobasesettings.md — локально, не в git"
Write-Host "4. MCP стек: .cursor/MCP_QUICK_START.md или MCP_LITE_DEVICE.md"
Write-Host "5. /doctor в Cursor для проверки"
Write-Host ""
Write-Host "Done." -ForegroundColor Green
