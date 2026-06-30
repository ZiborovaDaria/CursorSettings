# RULES_INDEX — ESTI

Карта правил, навыков и MCP для workspace ЭСТИ.

| Документ | Назначение |
|---|---|
| [INSTALL_OTHER_DEVICE.md](INSTALL_OTHER_DEVICE.md) | **Полный** чеклист ЭСТИ: MCP, litecode, Atlas, memory-bank |
| [INSTALL_ALL_PROJECTS.md](INSTALL_ALL_PROJECTS.md) | Все проекты `C:\Cursor\` |
| [MCP_QUICK_START.md](MCP_QUICK_START.md) | Быстрый старт MCP |
| [MCP_ROUTER_ESTI.md](MCP_ROUTER_ESTI.md) | Роутер MCP v4 |
| [MCP_TOOLS_MATRIX.md](MCP_TOOLS_MATRIX.md) | Матрица инструментов |
| [MCP_SETUP_ESTI.md](MCP_SETUP_ESTI.md) | Настройка MCP |
| [MCP_LITE_DEVICE.md](MCP_LITE_DEVICE.md) | Профиль LITE (слабый ПК) |

MCP-файлы: `mcp.profile.power.json`, `mcp.profile.lite.json` (активный `mcp.json` — локально). Шаблоны `export/`, `shared-bundle/`, `*.example` — только в [GitHub](https://github.com/ZiborovaDaria/CursorSettings); локально удаляются, restore через `Restore-DistributionBundleFromGit.ps1`.

## Always-on правила

| Файл | Назначение |
|---|---|
| `00-esti-core.mdc` | Продукт, политика, MCP, triage |
| `00-esti-device-profile.mdc` | POWER / LITE |
| `32-agent-caveman-esti.mdc` | Caveman для dev |
| `33-agent-error-learning-pipeline.mdc` | Ошибка → memory |
| `isolation_rules/Core/memory-bank-paths.mdc` | Memory Bank paths |
| `isolation_rules/` (visual-maps, Level1–4) | Supercode modes VAN…ARCHIVE |
| `.supercode/modes/memory-bank/*.yml` | Custom modes (extension supercode.supercode-sh) |

**Не хранить** `.cursor/rules/_archive/` — дубликат `isolation_rules/` (удаляется `Setup-MemoryBank-AllProjects.ps1`).

Коммуникация: `USER-RULES.md` в корне проекта.

## On-demand (сценарий → файл)

| Сценарий | Файл |
|---|---|
| Locate MCP | `03-mcp-locate.mdc` |
| Atlas POWER | `25-agent-bsl-atlas-esti.mdc` |
| Litecode | `27-agent-litecode-esti.mdc` |
| lean-ctx | `26-agent-lean-ctx-esti.mdc` |
| Verify | `34-agent-verification-checklist.mdc` |
| Debug | `35-agent-systematic-debugging.mdc` |
| Form module | `36-agent-form-reserved-names.mdc` |
| Metadata XML | `37-agent-metadata-xml-workarounds.mdc` |
| Async client | `38-agent-async-methods.mdc` |
| Locks | `39-agent-locks-and-transactions.mdc` |
| Platform traps | `40-agent-platform-solutions.mdc` |
| MCP playbooks | `41-agent-tooling-playbooks-esti.mdc` |

Полный список: `.cursor/rules/*.mdc`.

## MCP v4

| POWER | LITE |
|---|---|
| bsl-atlas-esti + litecode | litecode + code-index |
| Serena, naparnik, v8std | Serena, naparnik, v8std |

## Память (L0–L3)

| Слой | Путь |
|---|---|
| L0 | `memory-bank/` |
| L1 | lean-ctx `ctx_knowledge` |
| L2 | `.serena/memories/` |
| L3 | `.cursor/rules/*.mdc` |

## Команды Cursor

`/doctor` · `/handoff` · `/caveman` · `capture-error` · `reflect-lesson`

## Синхронизация между ПК

**В Git:** rules, skills/esti-project, MCP docs, profiles, scripts, export, `projects.manifest.json`.

**Локально:** `mcp.json`, `mcp.local.json`, `.dev.env`, `infobasesettings.md`, индексы Atlas/litecode.

**Workflow:** `git pull` → `Install-ESTI-OnNewDevice.ps1` → `Install-Project-OnNewDevice.ps1` → litecode/Atlas (см. INSTALL_OTHER_DEVICE §5) → Reload MCP.

**Пути (одинаковые на ПК):** `C:\Cursor\ESTI`, `C:\CursorMCP\`, `C:\bsl-atlas-indexes\ESTI`, `C:\bsl-litecode-data\ESTI`.

**device_profile:** POWER в main; LITE — локально + `mcp.profile.lite.json` → `mcp.json` (см. `MCP_LITE_DEVICE.md`).

**Обновление bundle:** `Export-CursorSettings.ps1` → `Spread-CursorSettings-ToProjects.ps1` → `git push`.
