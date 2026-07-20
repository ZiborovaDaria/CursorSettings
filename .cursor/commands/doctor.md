# /doctor — проверка правил и окружения

Проверь по чеклисту. Итог: таблица check / status (OK|WARNING|BLOCKER) / evidence. Секреты и пароли не печатать.

## A. Правила и Memory Bank

1. Есть ли `AGENTS.md`, `memory.md`, `.cursorrules`.
2. Есть ли `.cursor/rules/*.mdc` и корректный frontmatter (`alwaysApply` / description).
3. Есть ли команды: `van`, `plan`, `creative`, `implement`, `build`, `reflect`, `archive`, **`research-repo`**, **`checkmcp`**, **`evolve`**.
4. Есть ли старые активные дубли в `_legacy/*.mdc`; предложи `.mdc.off`.
5. Есть ли `memory-bank/tasks.md`, `activeContext.md`, `progress.md`.
6. Есть ли `.dev.env`; если нет — предложи `.dev.env.example`.
7. Skills из skill-router физически существуют (`~/.cursor/skills` / `.cursor/skills`).
8. `/implement` и `/build` не конфликтуют по смыслу.
9. OpenSpec optional-only.
10. **No WebFetch:** канон = § No WebFetch в `~/.cursor/rules/24-always-mcp-tool-router.mdc`. Project `26-always-no-webfetch.mdc` = stub (ссылка на канон). WARNING если stub разросся копией таблицы или в 24-always нет секции No WebFetch.

## B. Канон ИБ / MCP (без секретов)

11. HTTP ИБ = `http://localhost/BP_199_13` в project context / `infobasesettings.md` / `mcp.json` (согласованы).
12. Версия КФ в rules = **3.0.199.13**; если mcp-1c доступен — сверить с `get_configuration_info`.
13. Always-on: `24-always-mcp-tool-router.mdc` есть; **codegraph** не в активном роутере.
14. Выполнить или сослаться на `/checkmcp` и `memory-bank/checklists/mcp-smoke-after-reload.md`.
15. Внешний GitHub/URL research → `/research-repo` (не серия WebFetch).
16. Есть `LLM-RULES.md`; самоулучшение только через `/evolve`.

## C. Отчёт

17. Сводка: OK / WARNING / BLOCKER + next actions (Reload MCP, Reload Agent, fix path, …).
