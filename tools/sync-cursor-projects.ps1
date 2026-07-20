# Sync portable rules pack to C:\Cursor\<project>
param(
  [string]$PackRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent),
  [string[]]$Projects = @('BP','ESTI','KA','Obshep','UNF12_261','UPO','UT22_92','UT25_85')
)
# When script lives in tools/, PackRoot = repo root
if (-not (Test-Path (Join-Path $PackRoot '.cursor'))) {
  $PackRoot = Split-Path $PSScriptRoot -Parent
}
$ErrorActionPreference = 'Stop'
$cmds = @('research-repo.md','checkmcp.md','evolve.md','creative.md','doctor.md')
$rules = @(
  '26-always-no-webfetch.mdc',
  '1c-logging-strategy-agent.mdc',
  '1c-dcs-design-agent.mdc',
  '1c-registers-design-agent.mdc',
  '1c-verification-policy-agent.mdc',
  '24-always-mcp-tool-router.mdc',
  'lean-ctx.mdc',
  '1c-testing-release-agent.mdc'
)
foreach ($p in $Projects) {
  $root = "C:\Cursor\$p"
  if (-not (Test-Path $root)) { Write-Warning "skip $p"; continue }
  New-Item -ItemType Directory -Force -Path "$root\.cursor\commands","$root\.cursor\rules" | Out-Null
  foreach ($c in $cmds) { Copy-Item "$PackRoot\.cursor\commands\$c" "$root\.cursor\commands\$c" -Force }
  foreach ($r in $rules) {
    $src = Join-Path $PackRoot ".cursor\rules\$r"
    if (Test-Path $src) { Copy-Item $src "$root\.cursor\rules\$r" -Force }
  }
  Copy-Item "$PackRoot\LLM-RULES.md" "$root\LLM-RULES.md" -Force
  if (Test-Path "$PackRoot\.cursor\MCP_PLAYBOOKS.md") {
    Copy-Item "$PackRoot\.cursor\MCP_PLAYBOOKS.md" "$root\.cursor\MCP_PLAYBOOKS.md" -Force
  }
  Write-Host "SYNC $p"
}
$userRules = Join-Path $env:USERPROFILE '.cursor\rules'
if (Test-Path $userRules) {
  Copy-Item "$PackRoot\.cursor\rules\24-always-mcp-tool-router.mdc" "$userRules\24-always-mcp-tool-router.mdc" -Force
  Copy-Item "$PackRoot\.cursor\rules\lean-ctx.mdc" "$userRules\lean-ctx.mdc" -Force
  Write-Host 'USER ~/.cursor/rules refreshed'
}
