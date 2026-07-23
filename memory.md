<!-- DO NOT EDIT in project — synced from C:\1c-shared-patterns\cursor-addons\project-root\ -->

# memory.md — память проекта и маршрутизация v3 (+ Hub F+ Lite)

## Слои памяти

| Слой | Где | Что хранить | Когда использовать |
|---|---|---|---|
| L0 | `memory-bank/` | текущие задачи, планы, прогресс, reflection, archive | каждый нетривиальный workflow |
| L1 | lean-ctx `ctx_knowledge` | короткие pointers / локальные gotcha | перед fix; не дублировать тексты Hub |
| L1s | `C:\1c-shared-patterns\playbooks\agent-lessons\` | **переносимые** уроки агента (все КФ) | Hub Gate до генерации кода; promote после fail |
| L1p | `playbooks/content-patterns/` | эталоны HOW (CFE/EPF/…) | skill `reuse-1c-shared-patterns` |
| L2 | `.serena/memories/` | project + `pitfalls/shared/*` (cache) | быстрый graph; SoT lessons = Hub |
| L3 | Hub `cursor-addons/rules-shared/` → sync | жесткие shared rules (`hub-gate`, `global-04`) | Sync; копии в проекте не править руками |
| L3p | project `.cursor/rules/` overlays | `01-*-context`, `project-*`, mcp-first | только project-specific |

## Error → memory pipeline

```text
Detect
  → Recall (Hub agent-lessons/index + local reflection + Serena shared)
  → Fix
  → Verify
  → Store:
       portable → Hub agent-lessons + index.md → Sync-1cAgentPack.ps1
       local-only → memory-bank/reflection (+ local Serena)
  → Promote to alwaysApply only if repeated/critical (edit Hub rules-shared → Sync)
```

## Hub Gate (runtime)

Перед генерацией BSL/CFE/EPF/форм/Excel/query: index → max 2 файла → proof `KB:`.  
Skills: `consult-1c-shared-lessons`, `reuse-1c-shared-patterns`, `error-learning-1c`.

## Команды

- `capture-error` — разобрать ошибку, найти похожие случаи, предложить fix.
- `reflect-lesson` — записать урок (Hub vs local — по переносимости).
- `/reflect` — рефлексия по завершенной задаче.
- `/archive` — закрытие задачи.

## Не дублировать

- One-off ошибки не превращать сразу в `.mdc`.
- Систематический code-gen gotcha не оставлять только в project reflection.
- Секреты и локальные пароли не хранить в `memory.md`.
- Большие временные логи не хранить в Memory Bank; сохранять только выводы.
- Не править synced `hub-gate.mdc` / `global-04` в проекте — только в Hub.
