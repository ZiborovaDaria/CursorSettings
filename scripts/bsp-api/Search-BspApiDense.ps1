#Requires -Version 5.1
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Query,
    [int]$Top = 5,
    [switch]$Json,
    [switch]$WithDoc
)
$py = Join-Path $PSScriptRoot 'Search-BspApiDense.py'
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py -ErrorAction SilentlyContinue }
if (-not $python) { throw 'python/py not found' }
$argsList = @($py, $Query, '--top', "$Top")
if ($Json) { $argsList += '--json' }
if ($WithDoc) { $argsList += '--with-doc' }
& $python.Source @argsList
exit $LASTEXITCODE
