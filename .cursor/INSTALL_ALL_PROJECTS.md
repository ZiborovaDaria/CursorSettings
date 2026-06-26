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

### Шаг 3. ЭСТИ — дополнительные настройки (обязательно)

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

### Шаг 4. Проверка

`/doctor` в каждом workspace.  
ESTI: `Test-ESTI-MCPStack.ps1`

---

## Основной ПК — обновление всех проектов

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1
powershell -File .cursor\scripts\Export-CursorSettings.ps1
powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
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
| supercode | `.supercode/` | Install-Project |
| Memory Bank L0 | `memory-bank/`, `memory.md` | Install-Project (скелет) / git (ESTI) |
| Serena L2 | `.serena/memories/` | локально per project |
| Контекст КФ | `01-*-project-context.mdc` | в каждом проекте |
| MCP | `mcp.json`, MCP_ROUTER_* | локально per project |
| Litecode data | `C:\bsl-litecode-data\<ID>` | только ESTI (скрипт Prepare) |
| Atlas index | `C:\bsl-atlas-indexes\<ID>` | per project при POWER |

Манифест проектов: `projects.manifest.json`.

**Не для BSL:** `codegraph` — не подключать в 1С-проектах.
