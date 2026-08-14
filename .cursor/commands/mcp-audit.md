# /mcp-audit — KPI MCP vs native

Сравнить использование MCP и native tools по agent-transcripts (окно N дней vs предыдущие N).

1. Запусти:
   ```text
   powershell -NoProfile -ExecutionPolicy Bypass -File "C:\1c-shared-patterns\cursor-addons\install\Invoke-McpUsageAudit.ps1" -FailOnAlert
   ```
   Для другого проекта: `-TranscriptsRoot` + `-OutDir`.
2. Прочитай `_ai_agent/mcp-usage-audit-latest.txt` (или OutDir).
3. Если status=ALERT:
   - открой lesson `process-mcp-io-discipline`;
   - перечисли top нарушений (native Grep/Read на BSL, dual-channel, ctx_shell=0);
   - предложи точечный fix правил/поведения на следующую неделю.
4. Если WARN по `write_memory=0` — напомни Store после error-learning.
5. Короткий отчёт пользователю: baseline vs recent + alerts + 1–3 действия.

Порог по умолчанию: mcpShare≥40%, readMcp≥30%, grepMcp≥40%, shellMcp≥15%, nativeGrep≤250.
Рекомендуемая частота: раз в неделю или после крупного CFE-спринта.
