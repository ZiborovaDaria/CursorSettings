<#
.SYNOPSIS
  Sync F+ Lite agent pack from Hub to Cursor projects + global skills.
.PARAMETER WhatIf
  Dry-run only.
.PARAMETER Projects
  Optional subset of project names.
#>
param(
    [switch]$WhatIf,
    [string[]]$Projects = @()
)

$ErrorActionPreference = "Stop"
$InstallDir = $PSScriptRoot
$HubRoot = (Resolve-Path (Join-Path $InstallDir "..\..")).Path
$ManifestPath = Join-Path $InstallDir "sync-manifest.json"
$Manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

if ($Manifest.hubRoot -and (Test-Path -LiteralPath $Manifest.hubRoot)) {
    $HubRoot = $Manifest.hubRoot
}

$ProjectsRoot = $Manifest.projectsRoot
$TargetProjects = if ($Projects.Count -gt 0) { $Projects } else { @($Manifest.projects) }

function Copy-Tracked {
    param([string]$Src, [string]$Dst)
    if (-not (Test-Path -LiteralPath $Src)) { throw "Missing source: $Src" }
    $dstDir = Split-Path -Parent $Dst
    if ($WhatIf) {
        Write-Host "WHATIF: $Src -> $Dst"
        return
    }
    New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
    Copy-Item -LiteralPath $Src -Destination $Dst -Force
    Write-Host "OK $Dst"
}

Write-Host "HubRoot=$HubRoot"
Write-Host "WhatIf=$WhatIf"

foreach ($proj in $TargetProjects) {
    $projRoot = Join-Path $ProjectsRoot $proj
    if (-not (Test-Path -LiteralPath $projRoot)) {
        Write-Warning "Skip missing project: $projRoot"
        continue
    }
    Write-Host "=== $proj ==="
    foreach ($r in $Manifest.rules) {
        $src = Join-Path $HubRoot $r.src
        $dst = Join-Path $projRoot $r.dest
        Copy-Tracked -Src $src -Dst $dst
    }
    if ($Manifest.projectRoot) {
        foreach ($pr in $Manifest.projectRoot) {
            $src = Join-Path $HubRoot $pr.src
            $dst = Join-Path $projRoot $pr.dest
            Copy-Tracked -Src $src -Dst $dst
        }
    }
    foreach ($s in $Manifest.serena) {
        $src = Join-Path $HubRoot $s.src
        $dst = Join-Path $projRoot $s.dest
        Copy-Tracked -Src $src -Dst $dst
    }
}

$SkillsRoot = Join-Path $env:USERPROFILE ".cursor\skills"
Write-Host "=== global skills -> $SkillsRoot ==="
foreach ($sk in $Manifest.skills) {
    $src = Join-Path $HubRoot $sk.src
    $dstDir = Join-Path $SkillsRoot $sk.destName
    $dst = Join-Path $dstDir "SKILL.md"
    Copy-Tracked -Src $src -Dst $dst
}

# Remove obsolete long alwaysApply reuse rule from user rules if present (collapsed into gate+skill)
$obsoleteUserRule = Join-Path $env:USERPROFILE ".cursor\rules\shared-1c-pattern-reuse.mdc"
if (Test-Path -LiteralPath $obsoleteUserRule) {
    if ($WhatIf) {
        Write-Host "WHATIF: would remove obsolete $obsoleteUserRule"
    } else {
        Remove-Item -LiteralPath $obsoleteUserRule -Force
        Write-Host "REMOVED obsolete $obsoleteUserRule"
    }
}

Write-Host "DONE. Next: Check-1cAgentDrift.ps1 ; paste user-rules/hub-gate-snippet.md into Cursor User Rules ; Reload Window."
