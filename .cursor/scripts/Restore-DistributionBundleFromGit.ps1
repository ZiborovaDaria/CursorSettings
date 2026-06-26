#Requires -Version 5.1
<#
.SYNOPSIS
  Восстановить .cursor/export, shared-bundle и *.example из git (только для install/spread/export).

.EXAMPLE
  powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $repoRoot

$gitPaths = @(
    '.cursor/export',
    '.cursor/shared-bundle',
    '.dev.env.example',
    '.cursor/mcp.local.json.example'
)

$tracked = git ls-files $gitPaths
if (-not $tracked) {
    throw "No tracked distribution files in git. Clone https://github.com/ZiborovaDaria/CursorSettings.git"
}

foreach ($f in $tracked) {
    git update-index --no-skip-worktree $f 2>$null
}

git checkout HEAD -- $gitPaths
if ($LASTEXITCODE -ne 0) {
    throw "git checkout failed — run from CursorSettings repo root"
}

Write-Host "Distribution bundle restored from git." -ForegroundColor Green
