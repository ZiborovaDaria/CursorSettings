# /creative — проектное решение

Используй только если есть реальный выбор: архитектура, способ расширения, hook, структура EPF/ERF, интеграция, производительность, UI формы, сравнение внешних сводов правил.

## Шаблон

1. Problem.
2. Constraints.
3. Options A/B/C.
4. Trade-offs.
5. Decision.
6. Implementation notes.
7. Verification.
8. Rollback.

Сохрани результат в `memory-bank/creative/creative-YYYY-MM-DD-<topic>.md`.
После решения переходи к `/plan` или `/implement`.

## External URL / GitHub (No WebFetch)

Если в запросе есть `github.com` / внешний docs URL:

1. Следуй `/research-repo` и always-router **No WebFetch**.
2. Порядок: `uploads/*` → кэш `_sources/` → clone `%TEMP%` или `gh api` tree → `ctx_read`.
3. Один произвольный URL (не tree репо): `ctx_url_read`, не `WebFetch`.
4. Budget: **0** `WebFetch` по умолчанию; максимум **1** за весь CREATIVE с `WebFetch because: …`.
5. Документация 1С: naparnik / platform-docs / v8std — не веб-fetch «вместо MCP».
