# Idempotent setup for transcribe skill
$ErrorActionPreference = "Stop"
$skillRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$marker = Join-Path $skillRoot ".deps-ok"

if (Test-Path $marker) {
    Write-Host "transcribe deps OK (marker exists)"
    exit 0
}

# ffmpeg
$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
    Write-Warning "ffmpeg not found. Install: winget install ffmpeg"
    exit 1
}

# Python packages
$req = Join-Path $skillRoot "requirements.txt"
python -c "import faster_whisper" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing faster-whisper..."
    pip install -r $req
}

New-Item -ItemType File -Path $marker -Force | Out-Null
Write-Host "transcribe setup complete"
