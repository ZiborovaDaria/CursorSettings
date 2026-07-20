# /evolve — кандидаты в LLM-RULES.md

Самоулучшение правил **только** через этот поток. Автозапись запрещена.

## Алгоритм

1. **Собрать сигналы** (без WebFetch):
   - `memory-bank/reflection/*`;
   - правки пользователя в чате («не так», «всегда делай X»);
   - явные `rule-friction:`;
   - паттерн: >3 попыток `WebFetch` на один host / dual-channel Grep после успешного MCP.
2. Сформулировать **1–5 кандидатов**:

| # | Scope | Rule (1–3 предложения) | Why | Source | Conflict with always-on? |
|---|---|---|---|---|---|
| 1 | | | | | no/yes→BLOCKER |

3. **СТОП.** Показать таблицу. Ждать approve по каждому `#` (или reject).
4. После approve:
   - дописать в `LLM-RULES.md` → **Active** с датой;
   - при конфликте с `24-always` / No WebFetch / safe-scope / no-`&Вместо` → **не писать**, пометить BLOCKER.
5. Не трогать: `mcp.json`, типовую КФ, `_legacy` restore, always-on роутер без USER.

## Стартовый пример (предложить, не писать без approve)

- Scope: external URL  
- Rule: при GitHub URL сначала `/research-repo`; `WebFetch` = 0 default  
- Why: CREATIVE comol overfetch (Fetching page)  
- Source: `creative-2026-07-20-comol-ai-rules-1c.md` Meta  

## Отчёт

Список предложенных / approved / rejected / записанных id.
