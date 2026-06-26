#Requires -Version 5.1
<#
.SYNOPSIS
  Create memory-bank/ and memory.md for a project from projects.manifest.json.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId,
    [switch]$Force,
    [string]$ManifestPath
)

$ErrorActionPreference = 'Stop'
$settingsRepo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$manifestFile = if ($ManifestPath) { $ManifestPath } else { Join-Path $settingsRepo '.cursor\projects.manifest.json' }
$manifest = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
$proj = $manifest.projects | Where-Object { $_.id -eq $ProjectId } | Select-Object -First 1
if (-not $proj) { throw "Project not found: $ProjectId" }

$root = $proj.path
$mb = Join-Path $root 'memory-bank'
$date = Get-Date -Format 'yyyy-MM-dd'
$liteData = "C:\bsl-litecode-data\$ProjectId"
$litePort = $proj.litecodePort
$router = if ($proj.mcpRouter) { $proj.mcpRouter } else { $proj.mcpDocs[0] }
$contextRule = $proj.contextRule
$prefix = $proj.prefix
$title = $proj.title
if ($proj.xmlOnly) {
    $xmlNote = 'XML dump only (no live IB).'
} else {
    $xmlNote = 'Live IB - see infobasesettings.md.'
}

New-Item -ItemType Directory -Path $mb, (Join-Path $mb 'reflection'), (Join-Path $mb 'archive'), (Join-Path $mb 'creative') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $root 'handoffs') -Force | Out-Null

function Write-IfMissing {
    param([string]$Path, [string]$Content)
    if ((Test-Path $Path) -and -not $Force) { return }
    [IO.File]::WriteAllText($Path, $Content, [Text.UTF8Encoding]::new($false))
    Write-Host "  wrote: $Path"
}

Write-Host "=== Memory Bank: $ProjectId ===" -ForegroundColor Cyan

$brief = @"
# Project Brief — $ProjectId

## Назначение
**$title** — workspace ``$root``. Доработки в расширениях CFE (``Extent/``). Основную КФ не менять без явного разрешения.

## Режим
$xmlNote

## Цели разработки
- Минимальные доработки в CFE, префикс **$prefix**
- Locate: litecode + code-index (repo **$ProjectId**)

## Связанная память
- Правила: ``.cursor/rules/$contextRule``, ``33-agent-error-learning-pipeline.mdc``
- Роутер MCP: ``.cursor/$router``
- Карта слоёв: ``memory.md``
"@

$tech = @"
# Tech Context — $ProjectId

## Workspace
| Параметр | Значение |
|---|---|
| Путь | ``$root`` |
| Префикс CFE | **$prefix** |
| code-index repo | **$ProjectId** |

## Litecode
| Параметр | Значение |
|---|---|
| Данные | ``$liteData`` |
| MCP SSE | ``http://localhost:$litePort/sse`` |
| Подготовка | ``Prepare-LitecodeData.ps1 -ProjectId $ProjectId`` |
| Docker | ``.cursor/infra/litecode-$($ProjectId.ToLower())/docker-compose.fast.yml`` |
| Запуск | ``Start-Litecode-Project.ps1 -ProjectId $ProjectId`` |

Отчёт по КФ: ``$liteData\metadata\ОтчетПоКонфигурации.txt`` (для get_access).

## MCP
``.cursor/mcp.json``, ``.cursor/$router``

## Память агента
- L0: memory-bank/
- L1: lean-ctx ctx_knowledge
- L2: .serena/memories/
- L3: .cursor/rules/

## Скрипты (из ESTI)
- ``C:\Cursor\ESTI\.cursor\scripts\Prepare-LitecodeData.ps1``
- ``C:\Cursor\ESTI\.cursor\scripts\Start-Litecode-Project.ps1``
- ``C:\Cursor\ESTI\.cursor\scripts\Setup-AllProjects-LitecodeMemory.ps1``
"@

$product = @"
# Product Context — $ProjectId

## Продукт
**$title**

## Workspace
- Выгрузка КФ: ``$root``
- Расширения: ``$root\Extent\``
- $xmlNote
"@

$patterns = @"
# System Patterns — $ProjectId

## Архитектура доработок
- Типовая КФ только чтение; изменения в CFE (Extent/)
- Префикс: **$prefix**
- Аннотации: &Перед, &После, &ИзменениеИКонтроль
- Запрещено: &Вместо, ПродолжитьВызов()

## Locate - Edit - Verify
1. Locate: litecode, code-index (repo $ProjectId)
2. Edit: Serena
3. Verify: naparnik + v8std

## Конвейер ошибок
33-agent-error-learning-pipeline.mdc, memory.md
"@

$active = @"
# Active Context — $ProjectId

## Текущий фокус
Инициализация memory-bank и litecode ($date).

## Активная задача
См. memory-bank/tasks.md.

## Ссылки
- Роутер MCP: .cursor/$router
- Контекст: .cursor/rules/$contextRule
"@

$progress = @"
# Progress — $ProjectId

## Завершено
- [x] Scaffold memory-bank ($date)
- [x] Litecode data path $liteData

## В работе
- (нет)

## Архив
memory-bank/archive/
"@

$tasks = @"
# Tasks — $ProjectId

## Текущая задача
(не задана)

---
После завершения: reflection, archive, очистить этот файл.
"@

$reflectionReadme = @"
# Reflection documents

reflection-YYYY-MM-DD-slug.md

Триггер: reflect-lesson или 33-agent-error-learning-pipeline.mdc.
"@

$archiveReadme = "# Archive`n`narchive-YYYY-MM-DD-slug.md"
$creativeReadme = "# Creative phase`n`ncreative-feature-name.md"

$memory = @"
# Память проекта $ProjectId

Слои: memory-bank/ (L0), ctx_knowledge (L1), .serena/memories/ (L2), rules (L3).

Команды: capture-error, reflect-lesson, /doctor, /handoff

Litecode: порт $litePort, данные $liteData
Роутер: .cursor/$router
"@

Write-IfMissing (Join-Path $mb 'projectbrief.md') $brief
Write-IfMissing (Join-Path $mb 'techContext.md') $tech
Write-IfMissing (Join-Path $mb 'productContext.md') $product
Write-IfMissing (Join-Path $mb 'systemPatterns.md') $patterns
Write-IfMissing (Join-Path $mb 'activeContext.md') $active
Write-IfMissing (Join-Path $mb 'progress.md') $progress
Write-IfMissing (Join-Path $mb 'tasks.md') $tasks
Write-IfMissing (Join-Path $mb 'reflection\README.md') $reflectionReadme
Write-IfMissing (Join-Path $mb 'archive\README.md') $archiveReadme
Write-IfMissing (Join-Path $mb 'creative\README.md') $creativeReadme
Write-IfMissing (Join-Path $root 'memory.md') $memory

Write-Host "Done: $mb" -ForegroundColor Green
