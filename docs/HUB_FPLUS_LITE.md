# Hub F+ Lite — общая база знаний 1С для Cursor

Связано с [CursorSettings](https://github.com/ZiborovaDaria/CursorSettings) и установкой [.cursor/INSTALL_ALL_PROJECTS.md](../.cursor/INSTALL_ALL_PROJECTS.md).

## Зачем

Один Source of Truth для:

- эталонов CFE/EPF/ERF (`content-patterns`);
- переносимых уроков агента (`agent-lessons`);
- shared project-root docs (`AGENTS.md`, `memory.md`, `LLM-RULES.md`, `USER-RULES.md`);
- `hub-gate.mdc` + Serena `pitfalls/shared`.

Без Hub урок, исправленный в одной КФ, не виден в другой.

## Путь

```text
C:\1c-shared-patterns
C:\Cursor\1c-shared-patterns   ← junction
```

Внутри: `INSTALL-TRANSFER.md`, `cursor-addons/`, `playbooks/agent-lessons/`, `playbooks/content-patterns/`, `catalog/`.

## Установка на новом ПК

1. Скопировать каталог Hub (минимум `catalog`, `playbooks`, `tools`, `cursor-addons`).
2. Junctions (см. INSTALL_ALL §1b).
3. Sync:

```powershell
cd C:\1c-shared-patterns\cursor-addons\install
.\Sync-1cAgentPack.ps1
.\Check-1cAgentDrift.ps1
```

4. User Rules snippet: `cursor-addons/user-rules/hub-gate-snippet.md` → Cursor Settings → Rules → Reload.

## Runtime (агент)

Перед генерацией BSL/CFE/EPF/форм/Excel/query:

1. `playbooks/agent-lessons/index.md` → max **2** файла  
2. CFE/EPF → skill `reuse-1c-shared-patterns`  
3. В ответе: `KB: …` | `KB: none` | `KB: skip-cosmetic`

Переносимый урок после ошибки → `agent-lessons` + Sync, не только `memory-bank/reflection`.

## Что править где

| Что | Где править |
|---|---|
| Shared rules / AGENTS / LLM-RULES / lessons | только Hub → Sync |
| `01-*-project-context`, `project-*`, mcp-first | только в проекте |
| Global skills pack (99+) | CursorSettings export / Install-ESTI |
| Playwright scenarios | `tests/web/` проекта |

## Связь с CursorSettings

CursorSettings = глобальный Cursor (rules/skills/scripts/MCP profiles).  
Hub = знания 1С + agent pack для всех КФ.  
Оба нужны на новом ПК.

## Пример полной инструкции проекта

`C:\Cursor\UT25_85\.cursor\INSTALL_OTHER_DEVICE.md` (УТ + Hub + Playwright).
