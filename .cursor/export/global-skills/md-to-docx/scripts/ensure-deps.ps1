# Idempotent npm ci for md-to-docx skill
$ErrorActionPreference = "Stop"
$skillRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$nodeModules = Join-Path $skillRoot "node_modules\docx"

if (Test-Path $nodeModules) {
    exit 0
}

Push-Location $skillRoot
try {
    Write-Host "Installing md-to-docx deps (npm ci)..."
    npm ci --omit=dev
    New-Item -ItemType File -Path (Join-Path $skillRoot ".deps-ok") -Force | Out-Null
} finally {
    Pop-Location
}
