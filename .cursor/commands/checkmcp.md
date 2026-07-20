# /checkmcp — smoke MCP после reload

Чеклист (если есть): `memory-bank/checklists/mcp-smoke-after-reload.md`.  
Секреты не печатать. Не менять КФ / данные ИБ.

Канон ИБ/версии брать из **project context** (`.cursor/rules/*project*`, `infobasesettings.md`, `.dev.env`, `mcp.json`) — не хардкодить чужой проект.

## Алгоритм

1. Определить корень workspace (например `C:/Cursor/<Project>`).
2. Выполнить проверки и заполнить таблицу:

| # | Check | Tool | Expect | Result | Evidence |
|---|---|---|---|---|---|
| 1 | lean-ctx PathJail | `ctx_read` на `<root>/memory-bank/tasks.md` или `AGENTS.md` | нет escapes project root | | |
| 2 | lean-ctx search | `ctx_search` в `.cursor` | без jail error | | |
| 3 | mcp-1c (если в mcp.json) | `get_configuration_info` | имя КФ + версия ≈ project rules | | |
| 4 | HTTP / путь ИБ | сравнить docs ↔ mcp.json | совпадают с каноном проекта | | |
| 5 | No WebFetch | `26-always-no-webfetch.mdc` stub + § в `24-always-mcp-tool-router` | exists | | |
| 6 | atlas (опц.) | `bsl-atlas-*` stats/search | Up → OK; down → WARNING | | |
| 7 | code-index (опц.) | `health` | Up → OK; down → WARNING | | |

3. Статусы:
   - fail 1–3 → **BLOCKER** (для MCP-задач);
   - fail 6–7 → **WARNING** (docs-only можно продолжать);
   - 401 mcp-1c → BLOCKER + Reload MCP; предпочтительно NO_AUTH / без секретов в отчёте.

4. Метрики (если просят «с метриками» и есть скрипт):
   ```powershell
   python <project-or-BP>\scripts\mcp_usage_stats.py --since <date> --tag checkmcp-YYYYMMDD
   ```
   Смотреть также `webfetch_calls` / `ctx_url_read_calls`.

5. Отчёт: таблица + next actions. Не чинить MCP через `WebFetch`.
