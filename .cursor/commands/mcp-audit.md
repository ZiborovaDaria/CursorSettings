# /mcp-audit — KPI MCP vs native (ESTI)

Еженедельный или on-demand аудит по agent-transcripts. Пороги: mcpShare≥40%, nativeGrep≤250/7d.

## Быстрый запуск

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Cursor\ESTI\scripts\Invoke-McpUsageAudit-Project.ps1

powershell -NoProfile -ExecutionPolicy Bypass -File C:\Cursor\ESTI\scripts\Invoke-McpUsageAudit-Project.ps1 -Monthly

powershell -NoProfile -ExecutionPolicy Bypass -File C:\Cursor\ESTI\scripts\Invoke-McpUsageAudit-Project.ps1 -FailOnAlert
```

Общий движок: `C:\1c-shared-patterns\cursor-addons\install\Invoke-McpUsageAudit-Project.ps1`

## Артефакты

| Файл | Содержимое |
|------|------------|
| `_ai_agent/mcp-usage-audit-latest.json` | JSON baseline vs recent |
| `_ai_agent/mcp-usage-audit-latest.txt` | Краткий текст + ALERT |

## При ALERT

1. Lesson `process-mcp-io-discipline` (Hub).
2. Правило `global-08-always-mcp-kpi-enforcement.mdc`.
3. `memory-bank/checklists/hot-debug-bsl.md`.
4. Не включать code-index при живом bsl-atlas*.

## Cadence

- Еженедельно: `-Days 7`
- После CFE: `-Days 7 -FailOnAlert`
- Месяц: `-Monthly`
