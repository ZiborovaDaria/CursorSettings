#Requires -Version 5.1
<#
.SYNOPSIS
  Health-check MCP-стека ЭСТИ без секретов.
.EXAMPLE
  powershell -File .cursor/scripts/Test-ESTI-MCPStack.ps1
#>
[CmdletBinding()]
param(
    [switch]$Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Write-Check {
    param([string]$Name, [bool]$Ok, [string]$Detail = '')
    $icon = if ($Ok) { '[OK]' } else { '[FAIL]' }
    $color = if ($Ok) { 'Green' } else { 'Red' }
    if (-not $Quiet) {
        Write-Host "$icon $Name" -ForegroundColor $color
        if ($Detail) { Write-Host "     $Detail" -ForegroundColor DarkGray }
    }
    return $Ok
}

$results = @()

# Docker: bsl-atlas-esti
$atlasUp = $false
try {
    $atlas = docker ps --filter 'name=bsl-atlas-esti' --format '{{.Status}}' 2>$null
    $atlasUp = [bool]($atlas -match 'Up')
} catch { }
$results += Write-Check 'Docker bsl-atlas-esti' $atlasUp $(if (-not $atlasUp) { 'cd C:\bsl-atlas-indexes\ESTI && docker compose up -d' } else { $atlas })

# Docker: litecode
$liteUp = $false
try {
    $lite = docker ps --filter 'name=1c-metacode-esti' --format '{{.Status}}' 2>$null
    $liteUp = [bool]($lite -match 'Up')
} catch { }
$results += Write-Check 'Docker 1c-metacode-esti (litecode)' $liteUp $(if (-not $liteUp) { 'cd .cursor/infra/litecode-esti && docker compose up -d' } else { $lite })

# HTTP endpoints
$endpoints = @(
    @{ Name = '1C Apache /ESTI'; Url = 'http://localhost/ESTI' },
    @{ Name = 'bsl-atlas-esti MCP'; Url = 'http://localhost:8008/mcp' },
    @{ Name = 'litecode SSE'; Url = 'http://localhost:6004/sse' },
    @{ Name = '1c-naparnik MCP'; Url = 'http://localhost:8007/mcp' }
)

foreach ($ep in $endpoints) {
    $ok = $false
    if ($ep.Name -eq 'litecode SSE' -and $liteUp) {
        $ok = $true
    } else {
        try {
            $null = Invoke-WebRequest -Uri $ep.Url -Method Get -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
            $ok = $true
        } catch {
            if ($_.Exception.Response) { $ok = $true }
        }
    }
    $results += Write-Check $ep.Name $ok $ep.Url
}

# Atlas index status
$atlasScript = Join-Path $PSScriptRoot 'Get-BslAtlasIndexStatus-ESTI.ps1'
if (-not $Quiet -and (Test-Path -LiteralPath $atlasScript)) {
    Write-Host ''
    Write-Host '--- Atlas index ---' -ForegroundColor Cyan
    & $atlasScript 2>&1 | Select-Object -First 20
}

# Litecode data layout
$dataRoot = 'C:\bsl-litecode-data\ESTI'
$hasCode = Test-Path -LiteralPath (Join-Path $dataRoot 'code\ConfigDumpInfo.xml')
$metaDir = Join-Path $dataRoot 'metadata'
$hasReport = (Test-Path -LiteralPath $metaDir) -and @(Get-ChildItem -LiteralPath $metaDir -Filter '*.txt' -ErrorAction SilentlyContinue).Count -gt 0
$results += Write-Check 'Litecode data: code\ConfigDumpInfo.xml' $hasCode $dataRoot
$results += Write-Check 'Litecode data: metadata report' $hasReport $(if (-not $hasReport) { 'WARN: export Configuration report (optional for full graph)' } else { '' })

# Summary
$failed = @($results | Where-Object { -not $_ }).Count
if (-not $Quiet) {
    Write-Host ''
    if ($failed -eq 0) {
        Write-Host 'All checks passed.' -ForegroundColor Green
    } else {
        Write-Host "$failed check(s) failed. See MCP_QUICK_START.md and MCP_LITE_DEVICE.md." -ForegroundColor Yellow
    }
}

exit $(if ($failed -eq 0) { 0 } else { 1 })
