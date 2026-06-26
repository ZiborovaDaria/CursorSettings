#Requires -Version 5.1
<#
.SYNOPSIS
  Подготовить данные litecode: junction code/ + metadata/ для проекта 1С.

.PARAMETER ProjectId
  ID из projects.manifest.json (ESTI, BP, KA, …).

.PARAMETER SourcePath
  Путь к XML-выгрузке. По умолчанию — path из манифеста.

.PARAMETER TargetPath
  C:\bsl-litecode-data\<ID> по умолчанию.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId,
    [string]$SourcePath,
    [string]$TargetPath,
    [string]$ManifestPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$settingsRepo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$manifestFile = if ($ManifestPath) { $ManifestPath } else { Join-Path $settingsRepo '.cursor\projects.manifest.json' }
$manifest = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
$proj = $manifest.projects | Where-Object { $_.id -eq $ProjectId } | Select-Object -First 1
if (-not $proj) { throw "Project not found in manifest: $ProjectId" }

$src = if ($SourcePath) { $SourcePath } else { $proj.path }
$dst = if ($TargetPath) { $TargetPath } else { "C:\bsl-litecode-data\$ProjectId" }

if (-not (Test-Path -LiteralPath $src)) {
    throw "Source not found: $src"
}

$codeLink = Join-Path $dst 'code'
$metaDir = Join-Path $dst 'metadata'

foreach ($dir in @($dst, $metaDir)) {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created: $dir"
    }
}

if (Test-Path -LiteralPath $codeLink) {
    $item = Get-Item -LiteralPath $codeLink -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
        $target = ($item.Target | Select-Object -First 1)
        if ($target -ne $src) {
            Write-Warning "Junction exists but points to $target (expected $src)"
        } else {
            Write-Host "code/ junction OK -> $src"
        }
    } else {
        Write-Warning "code/ exists but is not a junction: $codeLink"
    }
} else {
    if ($PSCmdlet.ShouldProcess($codeLink, "Create junction -> $src")) {
        cmd /c mklink /J "$codeLink" "$src" | Out-Null
        Write-Host "Junction: $codeLink -> $src"
    }
}

$dumpInfo = Join-Path $codeLink 'ConfigDumpInfo.xml'
if (Test-Path -LiteralPath $dumpInfo) {
    Write-Host '[OK] ConfigDumpInfo.xml'
} else {
    Write-Warning "ConfigDumpInfo.xml not found in $codeLink"
}

$report = Get-ChildItem -LiteralPath $metaDir -Filter '*.txt' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($report) {
    Write-Host "[OK] Configuration report: $($report.Name)"
} else {
    Write-Warning "Configuration report missing in $metaDir"
    Write-Warning "Designer: save report to C:\bsl-litecode-data\$ProjectId\metadata\"
}

Write-Host "Data root: $dst | MCP port: $($proj.litecodePort)"
