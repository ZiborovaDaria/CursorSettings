#Requires -Version 5.1
<#
.SYNOPSIS
  Обновить .cursor/export из ~/.cursor (перед git push).

.EXAMPLE
  powershell -File .cursor\scripts\Export-CursorSettings.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$export = Join-Path $repoRoot '.cursor\export'

Write-Host "=== Export Cursor settings ===" -ForegroundColor Cyan

# Global rules
$rulesDst = Join-Path $export 'global-rules'
New-Item -ItemType Directory -Path $rulesDst -Force | Out-Null
Copy-Item (Join-Path $env:USERPROFILE '.cursor\rules\*.mdc') $rulesDst -Force
Write-Host "rules: $((Get-ChildItem $rulesDst -Filter *.mdc).Count)"

# Global skills (all)
$skillsSrc = Join-Path $env:USERPROFILE '.cursor\skills'
$skillsDst = Join-Path $export 'global-skills'
New-Item -ItemType Directory -Path $skillsDst -Force | Out-Null
robocopy $skillsSrc $skillsDst /E /NFL /NDL /NJH /NJS /nc /ns /np /XD node_modules __pycache__ .git | Out-Null
# cavecrew from .agents
$cavecrew = Join-Path $env:USERPROFILE '.agents\skills\cavecrew'
if (Test-Path $cavecrew) {
    $ccDst = Join-Path $skillsDst 'cavecrew'
    if (Test-Path $ccDst) { Remove-Item $ccDst -Recurse -Force }
    Copy-Item $cavecrew $ccDst -Recurse -Force
}
Write-Host "skills: $((Get-ChildItem $skillsDst -Directory).Count)"

# Global scripts
$scriptsDst = Join-Path $export 'global-scripts'
New-Item -ItemType Directory -Path $scriptsDst -Force | Out-Null
Copy-Item (Join-Path $env:USERPROFILE '.cursor\scripts\*') $scriptsDst -Force -ErrorAction SilentlyContinue
Write-Host "scripts: $((Get-ChildItem $scriptsDst -File).Count)"

# Templates
$tplSrc = Join-Path $env:USERPROFILE '.cursor\templates'
if (Test-Path $tplSrc) {
    $tplDst = Join-Path $export 'global-templates'
    robocopy $tplSrc $tplDst /E /NFL /NDL /NJH /NJS | Out-Null
    Write-Host "templates: OK"
}

# Supercode (from workspace)
$scSrc = Join-Path $repoRoot '.supercode'
if (Test-Path $scSrc) {
    $scDst = Join-Path $export 'supercode'
    if (Test-Path $scDst) { Remove-Item $scDst -Recurse -Force }
    Copy-Item $scSrc $scDst -Recurse -Force
    Write-Host "supercode: OK"
}

Write-Host "Done. Commit and push to GitHub." -ForegroundColor Green
