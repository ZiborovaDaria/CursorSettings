#Requires -Version 5.1
<#
.SYNOPSIS
  Настроить litecode + memory-bank для всех (или выбранных) проектов C:\Cursor\.

.EXAMPLE
  powershell -File .cursor\scripts\Setup-AllProjects-LitecodeMemory.ps1
  powershell -File .cursor\scripts\Setup-AllProjects-LitecodeMemory.ps1 -Projects BP,UT25_85
#>
[CmdletBinding()]
param(
    [string[]]$Projects,
    [string]$ManifestPath
)

$ErrorActionPreference = 'Stop'
$settingsRepo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$manifestFile = if ($ManifestPath) { $ManifestPath } else { Join-Path $settingsRepo '.cursor\projects.manifest.json' }
$manifest = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

$list = if ($Projects) {
    $manifest.projects | Where-Object { $_.id -in $Projects }
} else {
    $manifest.projects
}

$prep = Join-Path $PSScriptRoot 'Prepare-LitecodeData.ps1'
$mem = Join-Path $PSScriptRoot 'Initialize-MemoryBank.ps1'
$infra = Join-Path $PSScriptRoot 'New-LitecodeInfra.ps1'

foreach ($proj in $list) {
    if (-not (Test-Path $proj.path)) {
        Write-Warning "Skip missing path: $($proj.path)"
        continue
    }
    Write-Host "`n========== $($proj.id) ==========" -ForegroundColor Cyan
    & $prep -ProjectId $proj.id -ManifestPath $manifestFile
    & $mem -ProjectId $proj.id -ManifestPath $manifestFile
    & $infra -ProjectId $proj.id -ManifestPath $manifestFile
}

Write-Host ''
Write-Host '=== Summary ===' -ForegroundColor Green
foreach ($proj in $list) {
    if (-not (Test-Path $proj.path)) { continue }
    $mb = Test-Path (Join-Path $proj.path 'memory-bank\projectbrief.md')
    $lc = Test-Path "C:\bsl-litecode-data\$($proj.id)\code\ConfigDumpInfo.xml"
    $meta = (Get-ChildItem "C:\bsl-litecode-data\$($proj.id)\metadata\*.txt" -ErrorAction SilentlyContinue).Count -gt 0
    $port = $proj.litecodePort
    Write-Host "$($proj.id): memory-bank=$mb litecode-junction=$lc config-report=$meta port=$port"
    if (-not $meta) {
        Write-Host "  -> Export config report to C:\bsl-litecode-data\$($proj.id)\metadata\" -ForegroundColor Yellow
    }
}

Write-Host 'Start litecode for active project:'
Write-Host '  powershell -File C:\Cursor\ESTI\.cursor\scripts\Start-Litecode-Project.ps1 -ProjectId BP'
