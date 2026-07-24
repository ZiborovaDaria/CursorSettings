#Requires -Version 5.1
# Thin launcher → Extract-BspApi.py (UTF-8 Cyrillic-safe).
param(
    [string]$CfRoot = 'C:\Cursor\UT25_85',
    [string]$OutDir = 'C:\1c-shared-patterns\playbooks\bsp-api'
)
$py = Join-Path $PSScriptRoot 'Extract-BspApi.py'
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py -ErrorAction SilentlyContinue }
if (-not $python) { throw 'python/py not found in PATH' }
& $python.Source $py --cf-root $CfRoot --out-dir $OutDir
exit $LASTEXITCODE
