# Hub F+ Lite — общая база знаний 1С для Cursor

Связано с [CursorSettings](https://github.com/ZiborovaDaria/CursorSettings) и [.cursor/INSTALL_ALL_PROJECTS.md](../.cursor/INSTALL_ALL_PROJECTS.md).

## Зачем

Один Source of Truth для:

- эталонов CFE/EPF/ERF (`content-patterns`);
- переносимых уроков агента (`agent-lessons`);
- shared project-root docs (`AGENTS.md`, `memory.md`, `LLM-RULES.md`, `USER-RULES.md`);
- `hub-gate.mdc` + skills consult/reuse/error-learning.

Без Hub урок, исправленный в одной КФ, не виден в другой.

## Путь

```text
C:\1c-shared-patterns
C:\Cursor\1c-shared-patterns   ← junction
```

Внутри: `INSTALL-TRANSFER.md`, `cursor-addons/`, `playbooks/agent-lessons/`, `playbooks/content-patterns/`, `catalog/`, `scripts/`.

## Установка на новом ПК

1. Скопировать каталог Hub (минимум `catalog`, `playbooks`, `tools`, `scripts`, `cursor-addons`).
2. Junctions (см. INSTALL_ALL §1b).
3. Sync:

```powershell
cd C:\1c-shared-patterns\cursor-addons\install
.\Sync-1cAgentPack.ps1
.\Check-1cAgentDrift.ps1
```

4. User Rules snippet: `cursor-addons/user-rules/hub-gate-snippet.md` → Cursor Settings → Rules → Reload.
5. Dense indexes (один раз или после новых lessons):

```powershell
cd C:\1c-shared-patterns\scripts
python Index-HubDenseAll.py
```

Требуется Ollama `qwen3-embedding:4b` на `http://127.0.0.1:11434`.

## Runtime (агент) — Hub Gate v2

Перед **любой разработкой** (код, metadata, CFE/EPF, rules, scripts, deploy, tests):

1. Lessons: `agent-lessons/index.md` → при неясном match `Search-HubLessonsDense.py "<задача>" --top 3`
2. Patterns: `Search-ContentPatternsDense.py "<задача>" --top 3`
3. Max **2** файла Hub суммарно
4. Proof: `KB:` + `REUSE:`

**Не consult Hub:** чистый вопрос «как работает X в 1С» без правок → syntax-helper / naparnik / v8std.

Подробно: [HUB_KB_SEARCH.md](HUB_KB_SEARCH.md) (копия Hub `HOW-SEARCH.md`).

Переносимый урок после ошибки → `agent-lessons` + `catalog.jsonl` + dense rebuild + Sync.

## Что править где

| Что | Где править |
|---|---|
| Shared rules / AGENTS / memory / lessons | только Hub → Sync |
| `01-*-project-context`, `project-*`, mcp-first | только в проекте |
| Global skills pack (99+) | CursorSettings `.cursor/export/global-skills` → `~/.cursor/skills` |
| Playwright scenarios | `tests/web/` проекта |

## Связь с CursorSettings

CursorSettings = глобальный Cursor (rules/skills/scripts/MCP profiles).  
Hub = знания 1С + agent pack для всех КФ.  
Оба нужны на новом ПК.

## Убрано (2026-08-07)

- Serena memories (`write_memory` / sync `serena-shared`) — не использовались.
- `ctx_knowledge remember` как слой памяти 1С — заменён на Hub Store.
