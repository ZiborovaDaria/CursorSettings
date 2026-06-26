# Настройки Cursor — контекст конфигурации ЭСТИ

Общие правила, навыки и агенты 1С: `C:\Users\Admin\.cursor\` (см. `README-1C-SETTINGS.md`).

## Правила в этом workspace

| Префикс | Где редактировать | Назначение |
|---|---|---|
| `global-*.mdc` | `~/.cursor/rules/` + `sync-global-rules.ps1` | Общие для всех конфигураций |
| `01-esti-*.mdc`, `03-*.mdc` | здесь, `.cursor/rules/` | Только ЭСТИ / УНФ |

После правки общих правил:
```powershell
~\.cursor\scripts\sync-global-rules.ps1 -Projects C:\Cursor\ESTI
```

## Прочее

- `skills/esti-project/` — навык контекста
- `mcp.json` — MCP-серверы этого репозитория
