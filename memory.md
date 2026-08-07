<!-- DO NOT EDIT in project — synced from C:\1c-shared-patterns\cursor-addons\project-root\ -->

# memory.md — память проекта и маршрутизация v4 (Hub Gate v2)

## Слои памяти

| Слой | Где | Что хранить | Когда использовать |
|---|---|---|---|
| L0 | `memory-bank/` | задачи, планы, прогресс, reflection, archive | каждый нетривиальный workflow |
| L1s | `playbooks/agent-lessons/` | **переносимые** anti-gotcha (все КФ) | Hub Gate до разработки; Store после fail |
| L1p | `playbooks/content-patterns/` | эталоны HOW (reuse) | skill `reuse-1c-shared-patterns` при implement |
| L2 | Hub `cursor-addons/rules-shared/` → sync | `hub-gate`, `global-04` | Sync; копии в проекте не править руками |
| L2p | project `.cursor/rules/` overlays | `01-*-context`, `project-*` | только project-specific |

Каталог lessons: `agent-lessons/catalog.jsonl` (автоген: `scripts/Build-AgentLessonsCatalog.py`).  
How-to поиск: `playbooks/agent-lessons/HOW-SEARCH.md`.  
Dense: `Search-HubLessonsDense.py` / `Search-ContentPatternsDense.py` (rebuild: `Index-HubDenseAll.py`).

## Error → memory pipeline

```text
Detect
  → Recall (Hub lessons index/catalog + local reflection)
  → Fix
  → Verify
  → Store:
       portable → Hub agent-lessons + index.md + catalog.jsonl (Build-AgentLessonsCatalog.py)
       local-only → memory-bank/reflection/
  → Promote to alwaysApply only if repeated/critical (edit Hub rules-shared → Sync)
```

## Hub Gate v2 (runtime)

Разработка → lessons (`KB:`) + patterns (`REUSE:`).  
Consult-only без правок → platform MCP, не Hub.

## Команды

- `capture-error` — разобрать ошибку, найти похожие уроки в Hub.
- `reflect-lesson` — записать урок (Hub vs local — по переносимости).
- `/reflect` — рефлексия по завершенной задаче.
- `/archive` — закрытие задачи.

## Не дублировать

- One-off ошибки не превращать сразу в `.mdc`.
- Систематический gotcha не оставлять только в project reflection.
- Секреты не хранить в `memory.md`.
- Не править synced `hub-gate.mdc` / `global-04` в проекте — только в Hub.
