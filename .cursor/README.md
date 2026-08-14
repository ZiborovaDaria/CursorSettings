# Настройки Cursor — контекст конфигурации УТ

Общие правила, навыки и агенты 1С: `C:\Users\Admin\.cursor\` (см. `README-1C-SETTINGS.md`).

Канон имён правил: `.cursor/RULES_INDEX.md`.

## Правила в этом workspace

| Префикс | Где править | Назначение |
|---|---|---|
| `global-00`…`global-06` | shared pack / Hub (`global-04`) / user `05-always-*` | Always, все КФ |
| `01-ut-project-context.mdc` | здесь | Только УТ |
| `1c-*-agent`, `*-auto` | shared copies в каждом проекте | On-demand |
| `hub-gate.mdc` | Hub `rules-shared/` + Sync-1cAgentPack | Hub gate |

После правки Hub-shared:
```powershell
cd C:\1c-shared-patterns\cursor-addons\install
.\Sync-1cAgentPack.ps1
.\Check-1cAgentDrift.ps1
```

Точечный sync MCP-роутера из user-pack (если правили `~/.cursor/rules/05-always-mcp-tool-router.mdc`):
```powershell
~\.cursor\scripts\sync-global-rules.ps1 -Projects C:\Cursor\UT25_85
```
Осторожно: полный sync всего `~/.cursor/rules` поверх нового `global-00…04` без очистки legacy — не делать.

## Прочее

- `skills/ut-project/` — навык контекста
- `mcp.json` — MCP-серверы этого репозитория
