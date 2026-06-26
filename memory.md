# Память проекта ESTI — маршрутизация

Краткая карта слоёв. Детали: `.cursor/rules/33-agent-error-learning-pipeline.mdc`.

## Слои

| Слой | Где | Что хранить |
|------|-----|-------------|
| **L0** | `memory-bank/` | Задачи, reflection, archive (Memory Bank / Supercode) |
| **L1** | lean-ctx `ctx_knowledge` | Gotcha после ошибок (recall перед fix, remember после) |
| **L2** | `.serena/memories/` | Устойчивые инварианты; вход `mem:core` |
| **L3** | `.cursor/rules/*.mdc` | Жёсткие правила при повторе ≥2 или critical |

## Конвейер error → memory

```
Detect (check_1c_code, v8std, runtime)
  → Recall (ctx_knowledge, read_memory pitfalls, bsl-atlas)
  → Fix (MCP_ROUTER_ESTI)
  → Store (remember, write_memory, reflection/*.md)
  → Promote (.mdc) — редко
```

## Команды Cursor

- `capture-error` — recall по ошибке
- `reflect-lesson` — reflection + store
- `/doctor`, `/handoff`, `/caveman` — см. `.cursor/RULES_INDEX.md`

## Карта правил

`.cursor/RULES_INDEX.md` — always-on, on-demand, MCP, навыки.

## Не дублировать

- One-off ошибки — только L1 или reflection, не Serena
- 1c-templates-mcp не используется (достаточно Atlas + litecode + memories)
