#Requires -Version 5.1
<#
.SYNOPSIS
  Раскатать общие настройки Cursor на все проекты C:\Cursor\.

.EXAMPLE
  powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
  powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1 -Projects UT25_85,BP
#>
[CmdletBinding()]
param(
    [string[]]$Projects,
    [string]$ManifestPath,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$settingsRepo = if ($PSScriptRoot) { Resolve-Path (Join-Path $PSScriptRoot '..\..') } else { 'C:\Cursor\ESTI' }
$manifestFile = if ($ManifestPath) { $ManifestPath } else { Join-Path $settingsRepo '.cursor\projects.manifest.json' }
$bundle = Join-Path $settingsRepo '.cursor\shared-bundle'
$manifest = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

if ($Projects) {
    $list = $manifest.projects | Where-Object { $_.id -in $Projects }
} else {
    $list = $manifest.projects
}

# 1. Sync global rules to all project paths
$allPaths = $list | ForEach-Object { $_.path }
$syncScript = Join-Path $env:USERPROFILE '.cursor\scripts\sync-global-rules.ps1'
if ((Test-Path $syncScript) -and -not $WhatIf) {
    Write-Host "sync-global-rules..." -ForegroundColor Cyan
    & $syncScript -Projects $allPaths
}

foreach ($proj in $list) {
    $root = $proj.path
    if (-not (Test-Path $root)) {
        Write-Warning "Skip missing: $root"
        continue
    }
    Write-Host "`n=== $($proj.id) ===" -ForegroundColor Cyan

    $rulesDir = Join-Path $root '.cursor\rules'
    $cmdsDir = Join-Path $root '.cursor\commands'
    $scriptsDir = Join-Path $root '.cursor\scripts'
    New-Item -ItemType Directory -Path $rulesDir,$cmdsDir,$scriptsDir -Force | Out-Null

    # Rules: shared bundle (skip caveman for ESTI — keeps esti variant)
    $ruleFiles = Get-ChildItem (Join-Path $bundle 'rules\*.mdc')
    foreach ($rf in $ruleFiles) {
        if ($proj.id -eq 'ESTI' -and $rf.Name -eq '32-agent-caveman.mdc') { continue }
        if ($proj.id -eq 'ESTI' -and $rf.Name -eq '00-cursor-agent-core.mdc') { continue }
        $dest = Join-Path $rulesDir $rf.Name
        if ($WhatIf) { Write-Host "  rule: $($rf.Name)"; continue }
        Copy-Item $rf.FullName $dest -Force
    }

    # Commands
    foreach ($cf in Get-ChildItem (Join-Path $bundle 'commands\*.md')) {
        if ($WhatIf) { Write-Host "  cmd: $($cf.Name)"; continue }
        Copy-Item $cf.FullName (Join-Path $cmdsDir $cf.Name) -Force
    }

    # Project install script
    $installSrc = Join-Path $bundle 'scripts\Install-Project-OnNewDevice.ps1'
    if ((Test-Path $installSrc) -and (-not $WhatIf)) {
        Copy-Item $installSrc (Join-Path $scriptsDir 'Install-Project-OnNewDevice.ps1') -Force
    }

    # USER-RULES.md
    $userRulesTpl = Join-Path $bundle 'USER-RULES.template.md'
    if ((Test-Path $userRulesTpl) -and (-not $WhatIf)) {
        $ur = Get-Content $userRulesTpl -Raw -Encoding UTF8
        $ur = $ur -replace '\{\{PROJECT_ID\}\}', $proj.id
        $ur = $ur -replace '\{\{PROJECT_PATH\}\}', $proj.path
        [IO.File]::WriteAllText((Join-Path $root 'USER-RULES.md'), $ur, [Text.UTF8Encoding]::new($false))
    }

    # INSTALL_OTHER_DEVICE.md
    $installTpl = Join-Path $bundle 'INSTALL_OTHER_DEVICE.template.md'
    if ((Test-Path $installTpl) -and (-not $WhatIf)) {
        $doc = Get-Content $installTpl -Raw -Encoding UTF8
        $mcpDocs = ($proj.mcpDocs -join ', ')
        $xmlNote = if ($proj.xmlOnly) { '| XML-only | No live IB - code-index / Serena only |' } else { '' }
        $doc = $doc -replace '\{\{PROJECT_TITLE\}\}', $proj.title
        $doc = $doc -replace '\{\{PROJECT_ID\}\}', $proj.id
        $doc = $doc -replace '\{\{PROJECT_PATH\}\}', $proj.path
        $doc = $doc -replace '\{\{CONTEXT_RULE\}\}', $proj.contextRule
        $doc = $doc -replace '\{\{SKILL\}\}', $proj.skill
        $doc = $doc -replace '\{\{MCP_DOCS\}\}', $mcpDocs
        $doc = $doc -replace '\{\{XML_ONLY_NOTE\}\}', $xmlNote
        [IO.File]::WriteAllText((Join-Path $root '.cursor\INSTALL_OTHER_DEVICE.md'), $doc, [Text.UTF8Encoding]::new($false))
    }

    # RULES_INDEX lite
    if (-not $WhatIf) {
        $idx = @"
# RULES_INDEX — $($proj.id)

Глобальная карта: [CursorSettings/RULES_INDEX.md](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/RULES_INDEX.md)

Установка: ``.cursor/INSTALL_OTHER_DEVICE.md``

| Контекст | ``$($proj.contextRule)`` |
| Навык | ``$($proj.skill)`` |
| MCP | $mcpDocs |
"@
        [IO.File]::WriteAllText((Join-Path $root '.cursor\RULES_INDEX.md'), $idx, [Text.UTF8Encoding]::new($false))
    }

    Write-Host "  OK: rules, commands, USER-RULES, INSTALL_OTHER_DEVICE"
}

Write-Host "`nDone." -ForegroundColor Green
