#Requires -Version 5.1
<#
.SYNOPSIS
  Удалить локально шаблоны/экспорт — они остаются в GitHub. Для работы не нужны.

.DESCRIPTION
  После удаления git status чистый (skip-worktree).
  Восстановление: Restore-DistributionBundleFromGit.ps1

.EXAMPLE
  powershell -File .cursor\scripts\Remove-LocalDistributionBundle.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $repoRoot

$removeDirs = @(
    (Join-Path $repoRoot '.cursor\export'),
    (Join-Path $repoRoot '.cursor\shared-bundle')
)
$removeFiles = @(
    (Join-Path $repoRoot '.dev.env.example'),
    (Join-Path $repoRoot '.cursor\mcp.local.json.example')
)

foreach ($d in $removeDirs) {
    if (Test-Path $d) {
        Remove-Item $d -Recurse -Force
        Write-Host "removed: $d"
    }
}
foreach ($f in $removeFiles) {
    if (Test-Path $f) {
        Remove-Item $f -Force
        Write-Host "removed: $f"
    }
}

$gitPaths = @(
    '.cursor/export',
    '.cursor/shared-bundle',
    '.dev.env.example',
    '.cursor/mcp.local.json.example'
)
foreach ($f in (git ls-files $gitPaths)) {
    git update-index --skip-worktree $f 2>$null
}

Write-Host "`nBundle removed locally (still on GitHub)." -ForegroundColor Green
Write-Host "Restore before install/spread/export: .cursor\scripts\Restore-DistributionBundleFromGit.ps1"
