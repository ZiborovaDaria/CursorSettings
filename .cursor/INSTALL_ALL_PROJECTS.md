# Установка Cursor-настроек — все проекты `C:\Cursor\`

Репозиторий глобальных настроек: **[github.com/ZiborovaDaria/CursorSettings](https://github.com/ZiborovaDaria/CursorSettings)**

## Проекты

| ID | Продукт | Путь | Инструкция |
|---|---|---|---|
| ESTI | ЭСТИ УНФ 2.2.5.90 | `C:\Cursor\ESTI` | [INSTALL_OTHER_DEVICE.md](INSTALL_OTHER_DEVICE.md) — **полный чеклист** |
| BP | БП 3.0 | `C:\Cursor\BP` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| KA | КА 2.5 | `C:\Cursor\KA` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| Obshep | Общепит 3.0 | `C:\Cursor\Obshep` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UNF12_261 | УНФ 3.0.12 | `C:\Cursor\UNF12_261` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UPO | УПО 3.0.12 | `C:\Cursor\UPO` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UT22_92 | УТ 11.5.22 | `C:\Cursor\UT22_92` | `.cursor/INSTALL_OTHER_DEVICE.md` |
| UT25_85 | УТ 11.5.25 | `C:\Cursor\UT25_85` | `.cursor/INSTALL_OTHER_DEVICE.md` |

Файлы `INSTALL_OTHER_DEVICE.md` и `USER-RULES.md` в BP/KA/UT генерируются `Spread-CursorSettings-ToProjects.ps1`.

---

## Новый ПК — порядок действий

### Шаг 1. Глобально (один раз)

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1   # при необходимости
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Ставит:
- `~/.cursor/rules` (24), `~/.cursor/skills` (99)
- `sync-global-rules.ps1`, `sync-project-mcp.ps1`
- supercode, templates, skill deps

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

3. `USER-RULES.md` → Cursor Settings → Rules
4. Extension: **supercode.supercode-sh**
5. MCP Reload

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

---

## Основной ПК — обновление всех проектов

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1
powershell -File .cursor\scripts\Export-CursorSettings.ps1
powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
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

# Для каждого проекта:
cd C:\Cursor\UT25_85
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

---

## Что общее vs per-project

| Компонент | Где | Как синхронизируется |
|---|---|---|
| Global rules/skills | `~/.cursor/` | CursorSettings export + Install-ESTI |
| `global-*.mdc` | `.cursor/rules/` каждого проекта | `sync-global-rules.ps1` |
| Rules 32–41, 00-core | `.cursor/rules/` | `Spread-CursorSettings-ToProjects.ps1` |
| Commands | `.cursor/commands/` | Spread |
| supercode | `.supercode/modes/memory-bank/` | `Setup-MemoryBank-AllProjects.ps1` |
| isolation_rules | `.cursor/rules/isolation_rules/` | `Setup-MemoryBank-AllProjects.ps1` (шаблон ESTI) |
| Memory Bank L0 | `memory-bank/`, `memory.md` | `Setup-MemoryBank-AllProjects.ps1` |
| Serena L2 | `.serena/memories/` | локально per project |
| Контекст КФ | `00-*-core.mdc` / skill проекта | в каждом проекте |
| MCP | `mcp.json`, MCP_ROUTER_* | локально per project |
| Litecode data | `C:\bsl-litecode-data\<ID>` | `Setup-AllProjects-LitecodeMemory.ps1` + отчёт КФ |
| Atlas index | `C:\bsl-atlas-indexes\<ID>` | per project при POWER |

Манифест проектов: `projects.manifest.json`.

**Не для BSL:** `codegraph` — не подключать в 1С-проектах.
