<#
.SYNOPSIS
  Compare Hub shared pack hashes vs project copies / global skills.
  Exit 1 if drift.
#>
param(
    [string[]]$Projects = @()
)

$ErrorActionPreference = "Stop"
$InstallDir = $PSScriptRoot
$Manifest = Get-Content -LiteralPath (Join-Path $InstallDir "sync-manifest.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$HubRoot = $Manifest.hubRoot
if (-not (Test-Path -LiteralPath $HubRoot)) {
    $HubRoot = (Resolve-Path (Join-Path $InstallDir "..\..")).Path
}

$TargetProjects = if ($Projects.Count -gt 0) { $Projects } else { @($Manifest.projects) }
$drift = 0

function Assert-SameHash {
    param([string]$Src, [string]$Dst, [string]$Label)
    if (-not (Test-Path -LiteralPath $Src)) {
        Write-Host "MISSING SRC $Label : $Src"
        $script:drift++
        return
    }
    if (-not (Test-Path -LiteralPath $Dst)) {
        Write-Host "MISSING DST $Label : $Dst"
        $script:drift++
        return
    }
    $h1 = (Get-FileHash -LiteralPath $Src -Algorithm SHA256).Hash
    $h2 = (Get-FileHash -LiteralPath $Dst -Algorithm SHA256).Hash
    if ($h1 -ne $h2) {
        Write-Host "DRIFT $Label"
        Write-Host "  src=$Src"
        Write-Host "  dst=$Dst"
        $script:drift++
    } else {
        Write-Host "OK $Label"
    }
}

foreach ($proj in $TargetProjects) {
    $projRoot = Join-Path $Manifest.projectsRoot $proj
    if (-not (Test-Path -LiteralPath $projRoot)) {
        Write-Warning "Skip missing $proj"
        continue
    }
    Write-Host "=== $proj ==="
    foreach ($r in $Manifest.rules) {
        Assert-SameHash -Src (Join-Path $HubRoot $r.src) -Dst (Join-Path $projRoot $r.dest) -Label "$proj/$($r.dest)"
    }
    if ($Manifest.projectRoot) {
        foreach ($pr in $Manifest.projectRoot) {
            Assert-SameHash -Src (Join-Path $HubRoot $pr.src) -Dst (Join-Path $projRoot $pr.dest) -Label "$proj/$($pr.dest)"
        }
    }
    foreach ($s in $Manifest.serena) {
        Assert-SameHash -Src (Join-Path $HubRoot $s.src) -Dst (Join-Path $projRoot $s.dest) -Label "$proj/$($s.dest)"
    }
}

Write-Host "=== global skills ==="
foreach ($sk in $Manifest.skills) {
    $dst = Join-Path $env:USERPROFILE ".cursor\skills\$($sk.destName)\SKILL.md"
    Assert-SameHash -Src (Join-Path $HubRoot $sk.src) -Dst $dst -Label "skill/$($sk.destName)"
}

if ($drift -gt 0) {
    Write-Host "FAIL drift_count=$drift"
    exit 1
}
Write-Host "PASS no drift"
exit 0
