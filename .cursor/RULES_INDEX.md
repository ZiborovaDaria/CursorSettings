# RULES_INDEX — UT25_85

v3 Memory Bank + Agent Mode.

## Naming canon (все проекты `C:\Cursor`)

| Префикс | Пример | Роль |
|---|---|---|
| `global-NN-always-*` | `global-00` … `global-06` | Shared alwaysApply, одинаковые во всех КФ |
| `01-<code>-project-context` | `01-ut-project-context.mdc` | Overlay проекта (always) |
| `1c-*-agent` | `1c-code-writing-agent.mdc` | On-demand доменные агенты |
| `*-auto` | `windows-powershell-auto.mdc` | Glob / auto-attach |
| `memory-bank-*-agent` | `memory-bank-workflow-agent.mdc` | Memory Bank режимы |
| `project-<code>-*` | `project-esti-*.mdc` | Только конкретный проект |
| `hub-gate.mdc` | — | Hub SoT (`rules-shared/`), без `global-NN` |
| `lean-ctx.mdc` | — | Инструмент lean-ctx |

### Always shared (`global-NN`)

| NN | Файл |
|---|---|
| 00 | `global-00-always-1c-memory-bank-router.mdc` |
| 01 | `global-01-always-safe-scope.mdc` |
| 02 | `global-02-always-skill-router.mdc` |
| 03 | `global-03-always-memory-bank-paths.mdc` |
| 04 | `global-04-always-error-learning-trigger.mdc` (Hub) |
| 05 | `global-05-always-mcp-tool-router.mdc` |
| 06 | `global-06-always-no-webfetch.mdc` (stub → § No WebFetch в 05) |

Не использовать «голые» числа вроде `24-always` / `26-always` — только непрерывный ряд `global-00…NN`.

### Sync

- Hub F+ Lite: `C:\1c-shared-patterns\cursor-addons\install\Sync-1cAgentPack.ps1` → `hub-gate`, `global-04`.
- User-pack: `~/.cursor/rules/05-always-mcp-tool-router.mdc` ↔ project `global-05-…` (скрипт `sync-global-rules.ps1` добавляет префикс `global-`).
- **Не** гонять старый full-sync `~/.cursor/rules/*` поверх пакета `global-00…04` без ревизии SoT (legacy 00–40 там ещё лежит).

## Project map

| Контекст | `01-ut-project-context.mdc` |
| Навык | `ut-project` + `~/.cursor/skills` |
| MCP | `MCP_ROUTER.md`, `MCP_SETUP.md`, `global-05-always-mcp-tool-router.mdc` |
| Atlas | `bsl-atlas` |
| UI e2e | `tests/web/INSTALL.md` + `1c-web-test` |
