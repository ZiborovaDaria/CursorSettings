# /doctor — проверка правил и окружения

Проверь:

1. Есть ли `AGENTS.md`, `memory.md`, `.cursorrules`.
2. Есть ли `.cursor/rules/*.mdc` и корректный frontmatter.
3. Есть ли `.cursor/commands/van.md`, `plan.md`, `creative.md`, `implement.md`, `build.md`, `reflect.md`, `archive.md`.
4. Есть ли старые активные дубли в `_legacy/*.mdc`; предложи переименовать в `.mdc.off`.
5. Есть ли `memory-bank/tasks.md`, `activeContext.md`, `progress.md`.
6. Есть ли `.dev.env`; если нет — предложи скопировать `.dev.env.example`.
7. Проверить, что skills из skill-router физически существуют.
8. Проверить, что `/implement` и `/build` не конфликтуют.
9. Проверить, что OpenSpec optional-only.
10. Дать отчет: OK / WARNING / BLOCKER.
