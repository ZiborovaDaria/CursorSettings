#Requires -Version 5.1
<#
.SYNOPSIS
  Запустить litecode docker для проекта (уникальный порт на проект).

.EXAMPLE
  powershell -File Start-Litecode-Project.ps1 -ProjectId BP
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId,
    [ValidateSet('fast', 'full')]
    [string]$Profile = 'fast',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$settingsRepo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$manifest = Get-Content (Join-Path $settingsRepo '.cursor\projects.manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$proj = $manifest.projects | Where-Object { $_.id -eq $ProjectId } | Select-Object -First 1
if (-not $proj) { throw "Unknown project: $ProjectId" }

& (Join-Path $PSScriptRoot 'Prepare-LitecodeData.ps1') -ProjectId $ProjectId

$idLower = $ProjectId.ToLower()
$composeDir = Join-Path $proj.path ".cursor\infra\litecode-$idLower"
$composeFile = if ($Profile -eq 'full') { 'docker-compose.yml' } else { 'docker-compose.fast.yml' }
if (-not (Test-Path (Join-Path $composeDir $composeFile))) {
    & (Join-Path $PSScriptRoot 'New-LitecodeInfra.ps1') -ProjectId $ProjectId
}

$port = $proj.litecodePort
$listener = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($listener -and $Force) {
    $proc = Get-Process -Id $listener.OwningProcess -ErrorAction SilentlyContinue
    if ($proc) { Stop-Process -Id $proc.Id -Force; Write-Host "Freed port $port" }
} elseif ($listener) {
    Write-Warning "Port $port in use (PID $($listener.OwningProcess)). Use -Force or stop other litecode."
}

Push-Location $composeDir
try {
    docker compose -f $composeFile up -d
    docker ps --filter "name=1c-metacode-$idLower" --format '{{.Names}} {{.Status}}'
    Write-Host "litecode $ProjectId -> http://localhost:$port/sse"
} finally {
    Pop-Location
}
