#Requires -Version 5.1
<#
.SYNOPSIS
  Prepare litecode data layout: code/ junction + metadata/.
.PARAMETER TargetPath
  Data root (default C:\bsl-litecode-data\ESTI).
.PARAMETER SourcePath
  CF dump path (default C:\Cursor\ESTI).
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$TargetPath = 'C:\bsl-litecode-data\ESTI',
    [string]$SourcePath = 'C:\Cursor\ESTI'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourcePath)) {
    throw "Source not found: $SourcePath"
}

$codeLink = Join-Path $TargetPath 'code'
$metaDir = Join-Path $TargetPath 'metadata'
$reportFile = Join-Path $metaDir 'OtchetPoKonfiguracii.txt'
$reportFileRu = Get-ChildItem -LiteralPath $metaDir -Filter '*Konfiguracii*.txt' -ErrorAction SilentlyContinue | Select-Object -First 1

foreach ($dir in @($TargetPath, $metaDir)) {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created: $dir"
    }
}

if (Test-Path -LiteralPath $codeLink) {
    $item = Get-Item -LiteralPath $codeLink -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
        Write-Host "code/ junction exists: $($item.Target)"
    } else {
        Write-Warning "code/ exists but is not a junction: $codeLink"
    }
} else {
    if ($PSCmdlet.ShouldProcess($codeLink, 'Create junction to ESTI')) {
        cmd /c mklink /J "$codeLink" "$SourcePath" | Out-Null
        Write-Host "Junction: $codeLink -> $SourcePath"
    }
}

$dumpInfo = Join-Path $codeLink 'ConfigDumpInfo.xml'
if (Test-Path -LiteralPath $dumpInfo) {
    Write-Host '[OK] ConfigDumpInfo.xml found'
} else {
    Write-Warning "ConfigDumpInfo.xml not found in $codeLink"
}

if (-not (Test-Path -LiteralPath $reportFile) -and -not $reportFileRu) {
    Write-Warning "Configuration report missing: $reportFile"
    Write-Warning 'Export from 1C Designer: Configuration report -> metadata folder'
} else {
    Write-Host '[OK] Configuration report found'
}

Write-Host ''
Write-Host "Data root: $TargetPath"
Write-Host 'Next: cd .cursor/infra/litecode-esti; docker compose -f docker-compose.fast.yml up -d'
