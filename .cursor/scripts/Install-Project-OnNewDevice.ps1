#Requires -Version 5.1
<#
.SYNOPSIS
  Установка настроек одного проекта 1С (после глобального Install-ESTI-OnNewDevice).

.PARAMETER SettingsRepo
  Путь к клону CursorSettings (по умолчанию C:\Cursor\ESTI).
#>
[CmdletBinding()]
param(
    [string]$SettingsRepo = 'C:\Cursor\ESTI'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$userScripts = Join-Path $env:USERPROFILE '.cursor\scripts'

Write-Host "=== Install project: $projectRoot ===" -ForegroundColor Cyan

# Supercode
$scSrc = Join-Path $SettingsRepo '.cursor\export\supercode'
$scDst = Join-Path $projectRoot '.supercode'
if (Test-Path $scSrc) {
    if (Test-Path $scDst) { Remove-Item $scDst -Recurse -Force }
    Copy-Item $scSrc $scDst -Recurse -Force
    Write-Host "supercode -> .supercode/"
}

# VS Code extension recommendation
$vscodeDir = Join-Path $projectRoot '.vscode'
New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
$extSrc = Join-Path $SettingsRepo '.vscode\extensions.json'
if (Test-Path $extSrc) { Copy-Item $extSrc (Join-Path $vscodeDir 'extensions.json') -Force }

# handoffs
New-Item -ItemType Directory -Path (Join-Path $projectRoot 'handoffs') -Force | Out-Null

# memory-bank skeleton
$mb = Join-Path $projectRoot 'memory-bank'
if (-not (Test-Path $mb)) {
    $skel = Join-Path $SettingsRepo '.cursor\shared-bundle\memory-bank'
    if (Test-Path $skel) { Copy-Item $skel $mb -Recurse -Force; Write-Host "memory-bank/ created" }
}
if (-not (Test-Path (Join-Path $projectRoot 'memory.md'))) {
    $memSrc = Join-Path $SettingsRepo '.cursor\shared-bundle\memory.md'
    if (Test-Path $memSrc) { Copy-Item $memSrc (Join-Path $projectRoot 'memory.md') -Force }
}

# Sync global-* rules into this project
$sync = Join-Path $userScripts 'sync-global-rules.ps1'
if (Test-Path $sync) {
    & $sync -Projects $projectRoot
    Write-Host "global-* rules synced"
} else {
    Write-Warning "Run Install-ESTI-OnNewDevice.ps1 first (sync-global-rules.ps1 missing)"
}

Write-Host "Done. Read INSTALL_OTHER_DEVICE.md" -ForegroundColor Green
