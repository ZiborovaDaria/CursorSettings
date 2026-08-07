---
name: error-learning-1c
description: "Конвейер ошибка → recall → fix → verify → store → promote для 1С. После check_1c_code, v8std, runtime. Shared lessons → Hub agent-lessons."
---

# Error Learning 1C Skill

Use after failures and repeated mistakes.

## Pipeline

Detect → Recall → Fix → Verify → **Store (mandatory before done)** → Promote alwaysApply only if repeated/critical.

1. `C:\1c-shared-patterns\playbooks\agent-lessons\index.md` + `catalog.jsonl` (+ skill `consult-1c-shared-lessons`).
2. Project `memory-bank/reflection/`.
3. Project `project-*-error-learning-agent.mdc` for local paths if present.

## Store (same session — do not skip)

| Scope | Where | When |
|---|---|---|
| Portable across configs | `playbooks/agent-lessons/` + `index.md` + `catalog.jsonl` | default after check/runtime if gotcha not config-specific |
| Task / one config only | `memory-bank/reflection/reflection-YYYY-MM-DD-*.md` | local-only details |

Reply must include either:

- `STORED: hub:<lesson-id>` or `STORED: reflection:<path>`
- or `PROMOTE_DEFER: <why>`

After new Hub lesson: `python C:\1c-shared-patterns\scripts\Build-AgentLessonsCatalog.py` then `Index-HubLessonsDense.py`

- New alwaysApply `.mdc` only if repeated or critical → edit Hub `rules-shared` then Sync.
- Do not leave systematic code-gen gotchas only in one project's reflection.
- Portable lesson without Hub file = incomplete fix.

## Commands

- `capture-error` — recall by err text (Hub catalog/index)
- `reflect-lesson` — reflection + store (Hub vs local)
- `/mcp-audit` — KPI MCP vs native (weekly)
