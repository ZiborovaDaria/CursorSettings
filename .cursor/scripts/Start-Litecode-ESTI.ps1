#Requires -Version 5.1
<#
.SYNOPSIS
  Start litecode ESTI stack. Port 6004 must be free (stop do_main if needed).
.PARAMETER Force
  Stop litecode-group-1c-metacode-do_main-1 if it holds port 6004.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('fast', 'full')]
    [string]$Profile = 'fast',
    [switch]$Force
)

$composeDir = Join-Path $PSScriptRoot '..\infra\litecode-esti' | Resolve-Path
$composeFile = if ($Profile -eq 'full') { 'docker-compose.yml' } else { 'docker-compose.fast.yml' }

& (Join-Path $PSScriptRoot 'Prepare-LitecodeData-ESTI.ps1')

$blocker = docker ps --format '{{.Names}}' 2>$null | Where-Object { $_ -match 'metacode-do_main' }
if ($blocker -and $Force) {
    if ($PSCmdlet.ShouldProcess($blocker, 'Stop container blocking port 6004')) {
        docker stop $blocker | Out-Null
        Write-Host "Stopped: $blocker"
    }
} elseif ($blocker) {
    Write-Warning "Port 6004 may be used by $blocker. Run with -Force or stop manually."
}

Push-Location $composeDir
try {
    docker compose -f $composeFile up -d
    docker ps --filter name=1c-metacode-esti --format '{{.Names}} {{.Status}}'
} finally {
    Pop-Location
}
