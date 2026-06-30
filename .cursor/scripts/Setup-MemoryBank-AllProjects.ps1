#Requires -Version 5.1
<#
.SYNOPSIS
  Инициализация memory-bank + supercode memory-bank modes во всех проектах манифеста.

.EXAMPLE
  powershell -File .cursor\scripts\Setup-MemoryBank-AllProjects.ps1
  powershell -File .cursor\scripts\Setup-MemoryBank-AllProjects.ps1 -Projects KA,UT25_85
#>
[CmdletBinding()]
param(
    [string[]]$Projects,
    [string]$ManifestPath,
    [switch]$ForceSupercode,
    [switch]$ForceIsolationRules
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

$initMb = Join-Path $PSScriptRoot 'Initialize-MemoryBank.ps1'
$scSrc = Join-Path $settingsRepo '.supercode\modes\memory-bank'
$isoSrc = Join-Path $settingsRepo '.cursor\rules\isolation_rules'
$extSrc = Join-Path $settingsRepo '.vscode\extensions.json'

if (-not (Test-Path $scSrc)) { throw "Missing supercode template: $scSrc" }
if (-not (Test-Path (Join-Path $isoSrc 'visual-maps\van_mode_split\van-mode-map.mdc'))) {
    throw "Missing isolation_rules in ESTI: $isoSrc"
}

foreach ($proj in $list) {
    if (-not (Test-Path $proj.path)) {
        Write-Warning "Skip missing path: $($proj.path)"
        continue
    }
    Write-Host "`n========== $($proj.id) ==========" -ForegroundColor Cyan

    & $initMb -ProjectId $proj.id -ManifestPath $manifestFile

    $scDst = Join-Path $proj.path '.supercode\modes\memory-bank'
    $scSrcNorm = (Resolve-Path $scSrc).Path
    $scDstNorm = [IO.Path]::GetFullPath($scDst)
    if ($ForceSupercode -or -not (Test-Path (Join-Path $scDst 'van.yml'))) {
        if ($scSrcNorm -eq $scDstNorm) {
            Write-Host "  supercode modes OK (template in ESTI)"
        } else {
            New-Item -ItemType Directory -Path (Split-Path $scDst) -Force | Out-Null
            if (Test-Path $scDst) { Remove-Item $scDst -Recurse -Force }
            Copy-Item $scSrc $scDst -Recurse -Force
            Write-Host "  supercode modes -> .supercode/modes/memory-bank/"
        }
    } else {
        Write-Host "  supercode modes OK"
    }

    $isoDst = Join-Path $proj.path '.cursor\rules\isolation_rules'
    $isoSrcNorm = (Resolve-Path $isoSrc).Path
    $isoDstNorm = [IO.Path]::GetFullPath($isoDst)
    if ($ForceIsolationRules -or -not (Test-Path (Join-Path $isoDst 'visual-maps\van_mode_split\van-mode-map.mdc'))) {
        if ($isoSrcNorm -eq $isoDstNorm) {
            Write-Host "  isolation_rules OK (template in ESTI)"
        } else {
            New-Item -ItemType Directory -Path (Split-Path $isoDst) -Force | Out-Null
            if (Test-Path $isoDst) { Remove-Item $isoDst -Recurse -Force }
            Copy-Item $isoSrc $isoDst -Recurse -Force
            Write-Host "  isolation_rules -> .cursor/rules/isolation_rules/"
        }
    } else {
        Write-Host "  isolation_rules OK"
    }

    $vscodeDir = Join-Path $proj.path '.vscode'
    New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
    $extDst = Join-Path $vscodeDir 'extensions.json'
    if ((Test-Path $extSrc) -and ($extSrc -ne $extDst)) {
        Copy-Item $extSrc $extDst -Force
        Write-Host "  .vscode/extensions.json (supercode.supercode-sh)"
    }

    New-Item -ItemType Directory -Path (Join-Path $proj.path 'handoffs') -Force | Out-Null

    $archDst = Join-Path $proj.path '.cursor\rules\_archive'
    if (Test-Path $archDst) {
        Remove-Item $archDst -Recurse -Force
        Write-Host "  removed stale .cursor/rules/_archive/"
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Green
foreach ($proj in $list) {
    if (-not (Test-Path $proj.path)) { continue }
    $mb = Test-Path (Join-Path $proj.path 'memory-bank\projectbrief.md')
    $sc = Test-Path (Join-Path $proj.path '.supercode\modes\memory-bank\van.yml')
    $iso = Test-Path (Join-Path $proj.path '.cursor\rules\isolation_rules\visual-maps\van_mode_split\van-mode-map.mdc')
    Write-Host "$($proj.id): memory-bank=$mb supercode=$sc isolation_rules=$iso"
}

Write-Host "`nSupercode modes: VAN, PLAN, CREATIVE, IMPLEMENT, REFLECT, ARCHIVE"
Write-Host "Extension: supercode.supercode-sh"
