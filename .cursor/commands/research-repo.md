# /research-repo — дешёвое исследование внешнего Git-репо

Цель: оглавление + shortlist **без** `WebFetch` / Fetching page.

## Алгоритм (строго по порядку)

1. **Uploads:** если в чате есть `uploads/*` по этой ссылке — `ctx_read` / Read только его. Не refetch URL.
2. **Кэш:** есть `memory-bank/creative/_sources/<repo>-tree.md` — читать кэш, не сеть.
3. **Clone (предпочтительно):**
   ```powershell
   $d = Join-Path $env:TEMP '<repo-name>'
   if (-not (Test-Path $d)) { git clone --depth 1 --filter=blob:none <git-url> $d }
   ```
   Дальше: `ctx_tree` / `ctx_read` / `ctx_search` по `$d`. **Не** клонировать в `C:\Cursor\BP`.
4. **Альтернатива clone:** один вызов  
   `gh api repos/<owner>/<repo>/git/trees/<branch>?recursive=1`  
   → список путей; читать raw/файлы только по shortlist.
5. **Shortlist:** README + имена rules/commands/skills → gap-гипотеза → точечное чтение 3–10 файлов.
6. **Dedup:** имя skill/rule уже в `~/.cursor/skills` или `.cursor/rules` → пометить «уже есть», не тянуть тело.
7. **Кэш на выход (опц.):** записать `memory-bank/creative/_sources/<repo>-tree.md` (оглавление + 5–10 выжимок).
8. Для CREATIVE — сослаться на кэш/temp path в creative-note.

## Запрещено
- Серия `WebFetch` HTML `…/tree/…`, `api.github.com/.../contents/` пачками.
- `WebFetch` как primary.
- Писать в `mcp.json` / always-on чужой MCP-каталог.

## Если нужен один URL вне репо
`lean-ctx` `ctx_url_read` (`facts`/`markdown`, низкий `max_tokens`).  
`WebFetch` — только если `ctx_url_read` упал; ≤1; строка `WebFetch because: …`.
