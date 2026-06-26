# One-time / idempotent deps for ESTI global skills
$ErrorActionPreference = "Stop"
$skills = "$env:USERPROFILE\.cursor\skills"

Write-Host "=== ESTI skill deps ==="

$transcribeSetup = Join-Path $skills "transcribe\scripts\setup-once.ps1"
if (Test-Path $transcribeSetup) {
    Write-Host "transcribe..."
    & $transcribeSetup
}

$docxEnsure = Join-Path $skills "md-to-docx\scripts\ensure-deps.ps1"
if (Test-Path $docxEnsure) {
    Write-Host "md-to-docx..."
    & $docxEnsure
}

Write-Host "Done."
