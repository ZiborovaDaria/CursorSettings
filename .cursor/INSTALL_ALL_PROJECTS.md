# Установка Cursor-настроек — все проекты `C:\Cursor\`

Репозиторий глобальных настроек: **[github.com/ZiborovaDaria/CursorSettings](https://github.com/ZiborovaDaria/CursorSettings)**

## Проекты

| ID | Продукт | Путь | Инструкция |
|---|---|---|---|
| ESTI | ЭСТИ УНФ 2.2.5.90 | `C:\Cursor\ESTI` | [INSTALL_OTHER_DEVICE.md](INSTALL_OTHER_DEVICE.md) — **полный чеклист** |
| BP | БП 3.0 | `C:\Cursor\BP` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| KA | КА 2.5 | `C:\Cursor\KA` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| Obshep | Общепит 3.0 | `C:\Cursor\Obshep` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UNF | УНФ | `C:\Cursor\UNF` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UNF12_261 | УНФ 3.0.12 | `C:\Cursor\UNF12_261` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UPO | УПО 3.0.12 | `C:\Cursor\UPO` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UT22_92 | УТ 11.5.22 | `C:\Cursor\UT22_92` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UT25_85 | УТ 11.5.25 | `C:\Cursor\UT25_85` | `.cursor/INSTALL_OTHER_DEVICE.md` (**Hub + Playwright**) |
| RMK | РМК | `C:\Cursor\RMK` | `.cursor/INSTALL_OTHER_DEVICE.md` |

Общее для всех: [INSTALL_ALL_PROJECTS.md](INSTALL_ALL_PROJECTS.md) · Hub [docs/HUB_FPLUS_LITE.md](../docs/HUB_FPLUS_LITE.md) · Playwright [docs/PLAYWRIGHT_1C_WEB_TEST.md](../docs/PLAYWRIGHT_1C_WEB_TEST.md).

Файлы `AGENTS.md` / `memory.md` / `LLM-RULES.md` / `USER-RULES.md` / `hub-gate.mdc` раскатываются из Hub (`Sync-1cAgentPack.ps1`), не из Spread.

---

## Новый ПК — порядок действий

```text
1. CursorSettings (этот репо) → ~/.cursor
2. Hub C:\1c-shared-patterns → Sync agent pack
3. User Rules snippet (Hub Gate)
4. Workspace проекта + Install-Project
5. Litecode / Memory Bank (по необходимости)
6. Playwright (1c-web-test) если нужны веб-тесты
7. ИБ / MCP / Reload
```

### Шаг 1. Глобально CursorSettings (один раз)

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1   # при необходимости
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Ставит:
- `~/.cursor/rules`, `~/.cursor/skills` (в т.ч. база 1С-skills)
- `sync-global-rules.ps1`, `sync-project-mcp.ps1`
- supercode, templates, skill deps

**Не опираться** на длинный `~\.cursor\rules\shared-1c-pattern-reuse.mdc` как SoT — протокол генерации кода = **Hub Gate** (§1b).

### Шаг 1b. База знаний Hub (`1c-shared-patterns`) — обязательно для всех КФ

Общий SoT паттернов CFE/EPF + agent-lessons + sync pack правил/AGENTS/Serena.

1. Перенести каталог на ПК (см. `INSTALL-TRANSFER.md` внутри Hub), целевой путь:

```text
C:\1c-shared-patterns
```

Минимум: `catalog\`, `playbooks\`, `tools\`, `cursor-addons\`, `INSTALL-TRANSFER.md`.

2. Junctions:

```powershell
cmd /c mklink /J "C:\Cursor\1c-shared-patterns" "C:\1c-shared-patterns"
cmd /c mklink /J "%USERPROFILE%\1c-shared-patterns" "C:\1c-shared-patterns"
```

3. Раскатить agent pack во все проекты `C:\Cursor\*`:

```powershell
cd C:\1c-shared-patterns\cursor-addons\install
.\Sync-1cAgentPack.ps1 -WhatIf
.\Sync-1cAgentPack.ps1
.\Check-1cAgentDrift.ps1
```

Sync кладёт:

| Из Hub | Куда |
|---|---|
| `hub-gate.mdc`, `global-04-...` | `.cursor/rules/` каждого проекта |
| `AGENTS.md`, `memory.md`, `LLM-RULES.md`, `USER-RULES.md`, `.cursorrules` | корень каждого проекта |
| `serena-shared` | `.serena/memories/core_shared.md`, `pitfalls/shared/*` |
| skills consult / reuse / error-learning | `%USERPROFILE%\.cursor\skills\` |

4. **User Rules (Cursor Settings → Rules)** — вставить snippet:

```text
C:\1c-shared-patterns\cursor-addons\user-rules\hub-gate-snippet.md
```

Reload Window.

**Runtime:** перед генерацией BSL/CFE/EPF/форм/Excel/query → `playbooks\agent-lessons\index.md` (max 2 файла) → proof `KB: …`.  
Переносимые уроки → Hub `agent-lessons` + Sync, не только `memory-bank/reflection`.

Подробнее: [docs/HUB_FPLUS_LITE.md](../docs/HUB_FPLUS_LITE.md) · пример УТ: `C:\Cursor\UT25_85\.cursor\INSTALL_OTHER_DEVICE.md`.

### Шаг 1c. Playwright / веб-автотесты 1С

Канон UI e2e: skill **`1c-web-test`** + Playwright (не MCP puppeteer/screenshot).

```powershell
node -v   # 18+
cd "$env:USERPROFILE\.cursor\skills\1c-web-test\scripts"
npm install
# предпочтительно системный Chrome/Edge (bundled chromium часто зависает)
Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

В каждом проекте: `tests/web/INSTALL.md`, `.v8-project.json` с `webUrl`, веб-публикация ИБ.

Полный чеклист (пример УТ): `C:\Cursor\UT25_85\tests\web\INSTALL.md`  
Общий шаблон в репо: [docs/PLAYWRIGHT_1C_WEB_TEST.md](../docs/PLAYWRIGHT_1C_WEB_TEST.md).

### Шаг 2. Каждый проект

1. Скопировать workspace (git / robocopy), например `C:\Cursor\UT25_85`
2. В каталоге проекта:

```powershell
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

Скрипт создаёт при отсутствии:
- `memory-bank/` + `memory.md` (Memory Bank L0)
- `handoffs/`, `.supercode/`, `.vscode/extensions.json`
- синхронизирует `global-*.mdc`

3. Повторно `Sync-1cAgentPack.ps1` (§1b), если Hub ставили после клона проекта
4. Extension: **supercode.supercode-sh**
5. MCP Reload (`mcp.json` / `MCP_ROUTER_*` проекта)

User Rules для Hub Gate — из §1b (не путать с project `USER-RULES.md` = стиль caveman).

### Шаг 3. Litecode + Memory Bank (все проекты)

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Setup-AllProjects-LitecodeMemory.ps1
powershell -File .cursor\scripts\Setup-MemoryBank-AllProjects.ps1
```

**Litecode** — `Setup-AllProjects-LitecodeMemory.ps1` создаёт:
- `memory-bank/`, `memory.md`, `handoffs/`
- `C:\bsl-litecode-data\<ID>\` (junction + metadata)
- `.cursor/infra/litecode-<id>/docker-compose.fast.yml`
- уникальный порт litecode в `mcp.json`

**Memory Bank + Supercode** — `Setup-MemoryBank-AllProjects.ps1` создаёт/обновляет:
- `memory-bank/` (L0): `projectbrief.md`, `tasks.md`, `progress.md`, `reflection/`, `archive/`, `creative/`
- `.supercode/modes/memory-bank/` — custom modes: **VAN**, **PLAN**, **CREATIVE**, **IMPLEMENT**, **REFLECT**, **ARCHIVE**
- `.cursor/rules/isolation_rules/` — правила для Supercode (без дубликата `_archive/`)
- `.vscode/extensions.json` → `supercode.supercode-sh`

Принудительное обновление modes/rules из ESTI:

```powershell
powershell -File .cursor\scripts\Setup-MemoryBank-AllProjects.ps1 -ForceSupercode -ForceIsolationRules
```

После правки шаблонов modes в ESTI:

```powershell
powershell -File .cursor\scripts\Apply-SupercodeMemoryBankFixes.ps1
powershell -File .cursor\scripts\Setup-MemoryBank-AllProjects.ps1 -ForceSupercode
```

| ID | Litecode port | Данные |
|---|---|---|
| ESTI | 6004 | `C:\bsl-litecode-data\ESTI` |
| BP | 6005 | `C:\bsl-litecode-data\BP` |
| KA | 6006 | `C:\bsl-litecode-data\KA` |
| Obshep | 6007 | `C:\bsl-litecode-data\Obshep` |
| UNF12_261 | 6008 | `C:\bsl-litecode-data\UNF12_261` |
| UPO | 6009 | `C:\bsl-litecode-data\UPO` |
| UT22_92 | 6010 | `C:\bsl-litecode-data\UT22_92` |
| UT25_85 | 6011 | `C:\bsl-litecode-data\UT25_85` |

**Вручную для каждого проекта:** отчёт по конфигурации в `C:\bsl-litecode-data\<ID>\metadata\ОтчетПоКонфигурации.txt` (нужен для `get_access`).

**Запуск litecode** (каждый проект — свой compose и порт):

```powershell
powershell -File C:\Cursor\ESTI\.cursor\scripts\Start-Litecode-Project.ps1 -ProjectId ESTI
# или все сразу:
$ids = 'ESTI','BP','KA','Obshep','UNF12_261','UPO','UT22_92','UT25_85'
foreach ($id in $ids) { & powershell -File C:\Cursor\ESTI\.cursor\scripts\Start-Litecode-Project.ps1 -ProjectId $id }
```

Профиль **fast**: `ENABLE_EMBEDDING=false` — один MCP-tool `search_metadata` (14 op в JSON). Семантика: Atlas (POWER) или `search_by_embedding` при full-профиле.

**Не использовать** устаревший `litecode-group` из `C:\CursorMCP\1c-litecode-mcp\lite\` — только per-project `litecode-*-fast`.

### Шаг 4. ЭСТИ — доп. настройки (живая ИБ)

Только для `C:\Cursor\ESTI` — см. полный [INSTALL_OTHER_DEVICE.md](INSTALL_OTHER_DEVICE.md):

| Компонент | Действие |
|---|---|
| `.dev.env` | из `.dev.env.example` |
| `infobasesettings.md` | локально |
| `mcp.local.json` | секреты ИБ |
| **litecode** | `Prepare-LitecodeData-ESTI.ps1` + отчёт по КФ + docker |
| **bsl-atlas-esti** | `C:\bsl-atlas-indexes\ESTI` + Ollama |
| **code-index** | repo alias проекта |
| **ИБ + Apache** | `http://localhost/ESTI` |
| **Memory Bank** | уже в git для ESTI; для других — из Install-Project |

### Шаг 5. Проверка

`/doctor` в каждом workspace.  
ESTI: `Test-ESTI-MCPStack.ps1`  
Hub: `C:\1c-shared-patterns\cursor-addons\install\Check-1cAgentDrift.ps1` → PASS  
Генерация CFE-логики → в ответе строка `KB:`  
Playwright (если нужен): `tests/web` smoke / `node run.mjs start <webUrl>`

---

## Основной ПК — обновление всех проектов

| Компонент | Экспорт (`Export-CursorSettings.ps1`) | Установка (`Install-ESTI-OnNewDevice.ps1`) |
|---|---|---|
| Global rules | `.cursor/export/global-rules/` | `~/.cursor/rules/` |
| 1С skills | `.cursor/export/global-skills/` | `~/.cursor/skills/` |
| Caveman skills | `.cursor/export/agent-skills/` | `~/.agents/skills/` |
| Cursor skills | `.cursor/export/global-skills-cursor/` | `~/.cursor/skills-cursor/` |
| Subagents | `.cursor/export/global-agents/` | `~/.cursor/agents/` |
| Commands | `.cursor/export/global-commands/` + `shared-bundle/commands/` | Spread → `.cursor/commands/` |
| MCP profiles | `.cursor/export/mcp/` + `.cursor/mcp.profile.*.json` | `mcp.json` из профиля |
| Scripts | `.cursor/export/global-scripts/` | `~/.cursor/scripts/` |
| Supercode | `.cursor/export/supercode/` | workspace `.supercode/` |

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Export-CursorSettings.ps1
git add .cursor/export .cursor/shared-bundle/commands
git commit -m "chore: export global skills, agents, commands, mcp"
git push
powershell -File .cursor\scripts\Apply-SupercodeMemoryBankFixes.ps1
powershell -File .cursor\scripts\Setup-MemoryBank-AllProjects.ps1 -ForceSupercode
git add -A
git commit -m "chore: sync cursor settings all projects"
git push
powershell -File .cursor\scripts\Remove-LocalDistributionBundle.ps1   # опционально
```

На втором ПК:

```powershell
cd C:\Cursor\ESTI && git pull
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER

# Hub (если каталог обновили отдельно — robocopy/git):
cd C:\1c-shared-patterns\cursor-addons\install
.\Sync-1cAgentPack.ps1
.\Check-1cAgentDrift.ps1

# Для каждого проекта:
cd C:\Cursor\UT25_85
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

---

## Что общее vs per-project

| Компонент | Где | Как синхронизируется |
|---|---|---|
| Global rules/skills | `~/.cursor/` | CursorSettings export + Install-ESTI |
| **Hub patterns + lessons** | `C:\1c-shared-patterns` | перенос каталога + `Sync-1cAgentPack.ps1` |
| **hub-gate / AGENTS / LLM-RULES / shared Serena** | каждый проект | Sync из Hub (не Spread) |
| `global-*.mdc` (часть) | `.cursor/rules/` | `sync-global-rules.ps1` + Hub Sync для `global-04` |
| Commands | `.cursor/commands/` | Spread |
| supercode | `.supercode/modes/memory-bank/` | `Setup-MemoryBank-AllProjects.ps1` |
| isolation_rules | `.cursor/rules/isolation_rules/` | `Setup-MemoryBank-AllProjects.ps1` (шаблон ESTI) |
| Memory Bank L0 | `memory-bank/` | per project; `memory.md` из Hub Sync |
| Serena L2 shared | `.serena/memories/pitfalls/shared/` | Hub Sync |
| Контекст КФ | `01-*-project-context.mdc` / skill проекта | только в проекте |
| MCP | `mcp.json`, MCP_ROUTER_* | локально per project |
| **Playwright / 1c-web-test** | `~\.cursor\skills\1c-web-test` + `tests/web/` | Install skill + npm; сценарии в проекте |
| Litecode data | `C:\bsl-litecode-data\<ID>` | `Setup-AllProjects-LitecodeMemory.ps1` + отчёт КФ |
| Atlas index | `C:\bsl-atlas-indexes\<ID>` | per project при POWER |

Манифест проектов: `projects.manifest.json`.

**Не для BSL:** `codegraph` — не подключать в 1С-проектах.  
**UI e2e:** Playwright / `1c-web-test`, не MCP screenshot/puppeteer.
