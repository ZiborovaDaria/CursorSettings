---
name: reuse-1c-shared-patterns
description: Reuse shared 1C patterns from C:/1c-shared-patterns before any implementation. Use when creating or patching code, CFE/EPF/ERF, managed forms, print/MXL, Excel/XML exchange, rules, or scripts.
---

# Reuse 1C Shared Patterns

Hub root: `C:\1c-shared-patterns`  
How-to: `playbooks/agent-lessons/HOW-SEARCH.md`

## Порядок (при любой implement)

1. `python C:\1c-shared-patterns\scripts\Search-ContentPatternsDense.py "<задача>" --top 3` (score ≥0.55 = hit).
2. Fallback: `catalog\content_patterns_index.json` и `playbooks\content-patterns\`.
2. Источник Егора: `catalog\sources\egor\` (`artifact_index.json`, `unique_recipes.json`).
3. Затем `artifact_index.json` / `latest_versions.json` для эталона.
4. Открой карточку и исходники подтверждённого примера (1 эталон).
5. Только после этого генерируй/меняй BSL/XML/rules/scripts.

Также соблюдай Hub Gate: `playbooks\agent-lessons\index.md` (lessons, max 2 files total).

## Правила выбора

- `content-patterns` приоритетнее keyword-playbooks.
- Редкий, но ясный рабочий приём валиден.
- Последняя стабильная версия внутри `group_key`.
- Production source важнее заметок.
- Тот же продукт (`УТ`/`УНФ`/`БП`/`КА`/…) предпочтительнее чужого.
- Не использовать `codegraph` для BSL.
- Если близкого совпадения нет — `REUSE: none (искал: …)`.

## В ответе

`REUSE: <pattern-id>` или `REUSE: none (искал: …)` — вместе с `KB:` из hub-gate.
