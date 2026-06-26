# Move bulk isolation_rules to _archive (plan esti_rules_optimization)
$ErrorActionPreference = "Stop"
$src = Join-Path $PSScriptRoot "..\rules\isolation_rules"
$archive = Join-Path $PSScriptRoot "..\rules\_archive\isolation_rules"
New-Item -ItemType Directory -Path $archive -Force | Out-Null
$dirs = @('Level1','Level2','Level3','Level4','Phases','visual-maps')
foreach ($d in $dirs) {
    $from = Join-Path $src $d
    if (-not (Test-Path $from)) { continue }
    $to = Join-Path $archive $d
    if (Test-Path $to) { Remove-Item $to -Recurse -Force }
    Move-Item $from $to
    Write-Host "Archived $d"
}
Write-Host "Kept in isolation_rules:"
Get-ChildItem $src -Name
