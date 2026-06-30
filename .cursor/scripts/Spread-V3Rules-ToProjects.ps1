#Requires -Version 5.1
<#
.SYNOPSIS
  Раскатать v3 rules/commands на все проекты из projects.manifest.json.

.DESCRIPTION
  - Generic v3 rules из ESTI (без project-esti-*)
  - project-esti-* только в ESTI
  - Старые .mdc → .cursor/rules/_legacy/*.off
  - Сохраняет contextRule проекта из манифеста
  - Персонализирует global-02 (skill, context rule) для не-ESTI
#>
[CmdletBinding()]
param(
    [string[]]$Projects,
    [string]$ManifestPath,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'
$settingsRepo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$manifestFile = if ($ManifestPath) { $ManifestPath } else { Join-Path $settingsRepo '.cursor\projects.manifest.json' }
$manifest = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json

$list = if ($Projects) {
    $manifest.projects | Where-Object { $_.id -in $Projects }
} else {
    $manifest.projects
}

$v3RulesSrc = Join-Path $settingsRepo '.cursor\rules'
$v3CmdSrc = Join-Path $settingsRepo '.cursor\commands'
$rootFiles = @('AGENTS.md', 'memory.md', '.cursorrules', '.ai-rules-overlay.json')

function Move-LegacyRules {
    param([string]$RulesDir, [string[]]$KeepNames)
    $legacyDir = Join-Path $RulesDir '_legacy'
    New-Item -ItemType Directory -Force -Path $legacyDir | Out-Null
    $keep = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($n in $KeepNames) { [void]$keep.Add($n) }

    Get-ChildItem $RulesDir -Recurse -Filter '*.mdc' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\_legacy\\' } |
        ForEach-Object {
            if ($keep.Contains($_.Name)) { return }
            $rel = $_.FullName.Substring($RulesDir.Length + 1) -replace '\\', '__'
            $dest = Join-Path $legacyDir ($rel + '.off')
            if ($WhatIf) { Write-Host "    legacy: $rel"; return }
            Move-Item $_.FullName $dest -Force
        }

    Get-ChildItem $RulesDir -Directory -Recurse -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        ForEach-Object {
            if ($_.FullName -match '\\_legacy$') { return }
            if (-not (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue)) {
                if (-not $WhatIf) { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
            }
        }
}

function Copy-V3Rules {
    param(
        [string]$DestRules,
        [bool]$IncludeEstiProject,
        [string]$SourceRules = $v3RulesSrc
    )
    Get-ChildItem $SourceRules -Filter '*.mdc' -File | ForEach-Object {
        if ($_.Name -like 'project-esti-*' -and -not $IncludeEstiProject) { return }
        $dst = Join-Path $DestRules $_.Name
        if ((Test-Path -LiteralPath $dst) -and ((Get-Item $_.FullName).FullName -eq (Get-Item -LiteralPath $dst).FullName)) { return }
        if ($WhatIf) { Write-Host "    rule: $($_.Name)"; return }
        Copy-Item $_.FullName $dst -Force
    }
}

function Set-ProjectSkillRouter {
    param(
        [string]$RulesDir,
        [object]$Proj
    )
    if ($Proj.id -eq 'ESTI') { return }
    $path = Join-Path $RulesDir 'global-02-always-skill-router.mdc'
    if (-not (Test-Path $path)) { return }
    $content = Get-Content $path -Raw -Encoding UTF8
    $content = $content -replace 'MCP/code search \(ESTI\) \| `mcp-1c-tools` \(project\) \| `project-esti-mcp-router-agent\.mdc`',
        'MCP/code search | `1c-mcp-toolkit` (global) | `1c-mcp-first-search-agent.mdc`'
    $content = $content -replace 'Project context \(ESTI\) \| `esti-project` \| `project-esti-context-agent\.mdc`',
        "Project context | ``$($Proj.skill)`` | ``$($Proj.contextRule)``"
    $content = $content -replace 'Error learning \| `error-learning-1c` \| `project-esti-error-learning-agent\.mdc`',
        'Error learning | `error-learning-1c` | `global-04-always-error-learning-trigger.mdc`'
    $content = $content -replace '\| Orchestrator JSON \| `orchestrator-bridge` \| `project-esti-orchestrator-bridge-agent\.mdc` \|\r?\n', ''
    if (-not $WhatIf) {
        [IO.File]::WriteAllText($path, $content, [Text.UTF8Encoding]::new($false))
    }
    Write-Host "    global-02 patched for $($Proj.id)"
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
    $skillsDir = Join-Path $root '.cursor\skills'
    New-Item -ItemType Directory -Path $rulesDir, $cmdsDir -Force | Out-Null

    $keep = @(Get-ChildItem $v3RulesSrc -Filter '*.mdc' -File | ForEach-Object {
        if ($_.Name -like 'project-esti-*') {
            if ($proj.id -eq 'ESTI') { $_.Name }
        } else { $_.Name }
    })
    if ($proj.contextRule -and ($keep -notcontains $proj.contextRule)) {
        $ctxPath = Join-Path $rulesDir $proj.contextRule
        if (Test-Path $ctxPath) { $keep += $proj.contextRule }
    }

    Move-LegacyRules -RulesDir $rulesDir -KeepNames $keep
    Copy-V3Rules -DestRules $rulesDir -IncludeEstiProject:($proj.id -eq 'ESTI')
    Set-ProjectSkillRouter -RulesDir $rulesDir -Proj $proj

    foreach ($cf in Get-ChildItem $v3CmdSrc -File) {
        $cmdDst = Join-Path $cmdsDir $cf.Name
        if ($settingsRepo.Path -eq (Resolve-Path $root).Path) {
            if ((Test-Path -LiteralPath $cmdDst) -and ((Get-Item $cf.FullName).FullName -eq (Get-Item -LiteralPath $cmdDst).FullName)) { continue }
        }
        if ($WhatIf) { Write-Host "    cmd: $($cf.Name)"; continue }
        Copy-Item $cf.FullName $cmdDst -Force
    }

    foreach ($rf in $rootFiles) {
        $src = Join-Path $settingsRepo $rf
        if (-not (Test-Path $src)) { continue }
        $rfDst = Join-Path $root $rf
        if ($settingsRepo.Path -eq (Resolve-Path $root).Path) {
            if ((Test-Path -LiteralPath $rfDst) -and ((Get-Item $src).FullName -eq (Get-Item -LiteralPath $rfDst).FullName)) { continue }
        }
        if ($WhatIf) { Write-Host "    root: $rf"; continue }
        Copy-Item $src $rfDst -Force
    }

    if (Test-Path $skillsDir) {
        Get-ChildItem $skillsDir -Directory | Where-Object { $_.Name -ne $proj.skill -and $_.Name -ne 'mcp-1c-tools' -and $_.Name -ne 'orchestrator-bridge' } |
            ForEach-Object {
                if ($proj.id -eq 'ESTI') {
                    if ($_.Name -in @('esti-project', 'mcp-1c-tools', 'orchestrator-bridge')) { return }
                }
                if ($WhatIf) { Write-Host "    remove skill: $($_.Name)"; return }
                Remove-Item $_.FullName -Recurse -Force
            }
    }

    if ($proj.id -ne 'ESTI' -and -not $WhatIf) {
        $mcpDocs = ($proj.mcpDocs -join ', ')
        $idx = @"
# RULES_INDEX — $($proj.id)

v3 Memory Bank + Agent Mode. Глобальная карта: CursorSettings `.cursor/RULES_INDEX.md`.

| Контекст | ``$($proj.contextRule)`` |
| Навык | ``$($proj.skill)`` (project) + ``~/.cursor/skills`` (global) |
| MCP | $mcpDocs |
"@
        [IO.File]::WriteAllText((Join-Path $root '.cursor\RULES_INDEX.md'), $idx, [Text.UTF8Encoding]::new($false))
    }

    Write-Host "  OK"
}

# shared-bundle sync for git
$bundleRules = Join-Path $settingsRepo '.cursor\shared-bundle\rules'
$bundleCmd = Join-Path $settingsRepo '.cursor\shared-bundle\commands'
if (-not $WhatIf) {
    New-Item -ItemType Directory -Force -Path $bundleRules, $bundleCmd | Out-Null
    if (Test-Path $bundleRules) { Remove-Item $bundleRules\*.mdc -Force -ErrorAction SilentlyContinue }
    Get-ChildItem $v3RulesSrc -Filter '*.mdc' -File | Where-Object { $_.Name -notlike 'project-esti-*' } |
        Copy-Item -Destination $bundleRules -Force
    Get-ChildItem $v3CmdSrc -File | Copy-Item -Destination $bundleCmd -Force
    foreach ($f in @('memory.md')) {
        $s = Join-Path $settingsRepo $f
        if (Test-Path $s) { Copy-Item $s (Join-Path $settingsRepo ".cursor\shared-bundle\$f") -Force }
    }
    Write-Host "`nshared-bundle: v3 rules/commands synced" -ForegroundColor Green
}

Write-Host "`nDone." -ForegroundColor Green
