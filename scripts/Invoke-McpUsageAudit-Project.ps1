<#
.SYNOPSIS
  MCP usage audit for any Cursor 1C project under C:\Cursor.
.PARAMETER ProjectRoot
  e.g. C:\Cursor\UNF
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,
    [int]$Days = 7,
    [switch]$FailOnAlert,
    [switch]$Monthly
)

$ErrorActionPreference = 'Stop'
$SharedAudit = Join-Path $PSScriptRoot 'Invoke-McpUsageAudit.ps1'
if (-not (Test-Path -LiteralPath $SharedAudit)) {
    Write-Error "Missing: $SharedAudit"
}

$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$folder = Split-Path -Leaf $ProjectRoot
$slug = $folder -replace '_', '-'
$TranscriptsRoot = Join-Path $env:USERPROFILE ".cursor\projects\c-Cursor-$slug\agent-transcripts"
$OutDir = Join-Path $ProjectRoot '_ai_agent'

if ($Monthly) { $Days = 30 }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

if (-not (Test-Path -LiteralPath $TranscriptsRoot)) {
    Write-Warning "No transcripts: $TranscriptsRoot - audit skipped."
    exit 0
}

Write-Host ('=== ' + $folder + ' MCP audit (' + $Days + ' days) ===') -ForegroundColor Cyan
& $SharedAudit -TranscriptsRoot $TranscriptsRoot -OutDir $OutDir -Days $Days -FailOnAlert:$FailOnAlert
$reportPath = Join-Path $OutDir 'mcp-usage-audit-latest.txt'
Write-Host "Report: $reportPath" -ForegroundColor Green
