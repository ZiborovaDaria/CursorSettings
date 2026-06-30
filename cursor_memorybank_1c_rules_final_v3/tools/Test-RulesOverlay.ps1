param(
    [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$required = @(
    "AGENTS.md",
    "memory.md",
    ".cursorrules",
    ".cursor/RULES_INDEX.md",
    ".cursor/rules/global-00-always-1c-memory-bank-router.mdc",
    ".cursor/rules/1c-code-writing-agent.mdc",
    ".cursor/rules/project-esti-mcp-router-agent.mdc",
    ".cursor/commands/implement.md",
    ".cursor/commands/deploy_and_test.md",
    ".cursor/commands/capture-error.md",
    "memory-bank/tasks.md"
)

$missing = @()
foreach ($rel in $required) {
    $path = Join-Path $Root $rel
    if (-not (Test-Path $path)) { $missing += $rel }
}

$projectSkills = @(
    "esti-project",
    "mcp-1c-tools",
    "orchestrator-bridge"
)
$globalSkills = @(
    "1c-project",
    "1c-cfe-full-cycle",
    "1c-epf-full-cycle",
    "1c-erf-build",
    "1c-metadata-manage",
    "1c-form-managed",
    "1c-query-optimization",
    "1c-testing-release",
    "1c-yaxunit",
    "error-learning-1c",
    "handoff",
    "powershell-windows"
)
$globalRoot = Join-Path $env:USERPROFILE ".cursor/skills"

foreach ($s in $projectSkills) {
    $path = Join-Path $Root ".cursor/skills/$s/SKILL.md"
    if (-not (Test-Path $path)) { $missing += ".cursor/skills/$s/SKILL.md" }
}
foreach ($s in $globalSkills) {
    $path = Join-Path $globalRoot "$s/SKILL.md"
    if (-not (Test-Path $path)) { $missing += "~/.cursor/skills/$s/SKILL.md" }
}

if ($missing.Count -gt 0) {
    Write-Host "BLOCKER: missing files" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" }
    exit 1
}

$legacyActive = Get-ChildItem -Path (Join-Path $Root ".cursor/rules") -Recurse -Filter "*.mdc" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "_legacy|_archive" }
if ($legacyActive) {
    Write-Host "WARNING: active legacy/archive .mdc files found. Rename to .mdc.off if they duplicate v3:" -ForegroundColor Yellow
    $legacyActive | ForEach-Object { Write-Host " - $($_.FullName)" }
}

Write-Host "OK: Rules overlay v3 structure is present." -ForegroundColor Green
