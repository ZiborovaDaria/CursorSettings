---
name: consult-1c-shared-lessons
description: Consult shared 1C agent lessons before any development work, and after check_1c_code/runtime failures. Use when implementing, fixing repeated mistakes, or promoting portable lessons to the Hub.
---

# Consult 1C Shared Lessons

Hub: `C:\1c-shared-patterns\playbooks\agent-lessons\`  
How-to: `HOW-SEARCH.md`

## When

- Before any **development** (code, metadata, CFE/EPF/ERF, forms, rules, scripts, deploy, tests).
- **Not** for consult-only questions («как работает X в 1С») without edits — use syntax-helper / naparnik.
- After failed check/review/runtime when looking for known gotchas.
- When promoting a portable lesson out of project reflection.

## Steps

1. Read `index.md` (one screen table).
2. If no clear match: `python C:\1c-shared-patterns\scripts\Search-HubLessonsDense.py "<задача>" --top 3` (fallback: `Build-AgentLessonsCatalog.py --search`; score ≥0.55 = hit).
3. Open **at most 1** lesson file (with patterns — суммарно 2, см. hub-gate).
4. Apply required behavior.
5. Reply with `KB: <ids>` or `KB: none` (or `KB: skip-cosmetic`).
   On hit: add one short Required-behavior phrase from the opened file.

Do **not** read the whole Hub.  
Patterns HOW → skill `reuse-1c-shared-patterns` → `REUSE:`.

## Promote

Portable lesson → new file from `_template.md` + row in `index.md` →  
`Build-AgentLessonsCatalog.py` → `Index-HubLessonsDense.py` → Sync agent pack.
