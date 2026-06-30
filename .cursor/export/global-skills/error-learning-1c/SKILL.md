---
name: error-learning-1c
description: "Конвейер ошибка → recall → fix → verify → store → promote для 1С. После check_1c_code, v8std, runtime."
---

# Error Learning 1C Skill

Use after failures and repeated mistakes.

## Pipeline

Detect → Recall → Fix → Verify → Store → Promote only if repeated/critical.

## Rules

1. Always: `global-04-always-error-learning-trigger.mdc`
2. If workspace has `project-*-error-learning-agent.mdc` — load it for project-specific MCP/store paths.

## Commands

- `capture-error` — recall by error text
- `reflect-lesson` — reflection + store
