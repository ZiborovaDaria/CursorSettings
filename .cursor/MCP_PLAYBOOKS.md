# MCP Playbooks (project-agnostic)

Канон: `global-05-always-mcp-tool-router.mdc` + `MCP_ROUTER.md`.  
Overlay проекта: `01-*-project-context.mdc`, `.dev.env`, `mcp.json`.  
**Без** codegraph, WebFetch-spam, MCP screenshot/puppeteer, project-suffixed atlas в shared-правилах.

## BSL: consult → locate → edit → verify

LLM слабо знает корректный 1С-код — **сначала знания, потом генерация**.

1. **Consult KB** — `consult-1c-shared-lessons` (max 2); CFE/EPF/формы → `reuse-1c-shared-patterns`. Строка `KB: …`.
2. **Locate**
   - Up: `bsl-atlas` — `search_function` / `codesearch` / `code_grep` → `read_function`.
   - Down: code-index (`repo`=<project>) + litecode (`get_routines` / `get_routine_body` / `find_routines_by_description`).
3. **Структура** — `get_object_details` / litecode `object_structure` / `get_children` (имена реквизитов не выдумывать).
4. **Impact** — `get_callers` / `get_call_graph` / `verify_call`.
5. **Справка** — syntax-helper / Atlas `help.search` / `onec_help` / `config_help` / v8std / code-index `repo=docs`.
6. **Edit** — Serena после шагов 1–5.
7. **Verify** — `check_1c_code` → `review_1c_code` → `verify_field`/`verify_call`; при fail — снова Hub + error-learning.
8. Сдача — политика verify / deploy_and_test.

## Метаданные / типовой объект

1. litecode `browse`/`object_structure` или Atlas `metadatasearch`→`get_object_details`.
2. Движения / USED_IN → litecode `get_references`.
3. Живая ИБ → `mcp-1c`.
4. Методика КФ → naparnik `config_help` (имя из project ctx).

## Форма (managed)

1. Atlas `get_form_info` / litecode `get_form` / `mcp-1c.get_form_structure`.
2. Rules + form skills; Hub patterns при нетривиальной UI.
3. Validate form skill.
4. UI smoke: **Playwright** (`tests/web/`, skill `1c-web-test`) — не MCP browser.

## Запрос / производительность

1. `1c-query-optimization` + queries-performance agent.
2. `mcp-1c.validate_query` до execute.
3. Параметры, без конкатенации ввода.
4. `check_1c_code` `check_type=performance` при N+1 рисках.

## CFE patch

1. Locate + callers + Hub CFE lessons.
2. `&Перед` / `&После` / `&ИзменениеИКонтроль`.
3. `&Вместо` — только явный OK + rollback.
4. Verify: `check_1c_code`.

## Runtime ИБ

1. `mcp-1c` по project mcp.json.
2. OData: `1c-rest-mcp` только явно.

## Docs / стандарты / indexed Hub

| Нужно | Tool |
|---|---|
| Уроки агента | `consult-1c-shared-lessons` / `repo=docs` |
| Эталоны реализации | `reuse-1c-shared-patterns` / `repo=docs` |
| Docs прикладной КФ | naparnik `config_help` |
| ITS | `its_help` → `fetch_its` |
| Платформенный API | syntax-helper / Atlas `help.search` / `onec_help` |
| Стандарты / diagnostics | v8std |
| Style | `review_1c_code` |

## UI / web e2e

См. `tests/web/INSTALL.md`. Skill: `1c-web-test`.  
Не использовать MCP `screenshot` / `puppeteer-real-browser`.

## External GitHub / URL

1. `/research-repo`: uploads → `%TEMP%` clone / `gh api` → `ctx_read`.
2. Один URL: `ctx_url_read`.
3. Не серия `WebFetch`.

## lean-ctx: hit + shell (токены)

1. `ctx_read`: без `fresh` по умолчанию; повтор → Fn-ref `Fn`; explore = `map`/`signatures`/`lines`; `full` только перед edit; после edit = `diff`.
2. `ctx_shell` (PowerShell): pipeline `$_`, cmdlets из allowlist; не изобретать `$weirdVar`. BLOCKED → переписать без `$` или `lean-ctx allow $var` (не native Shell в обход).
3. Канон PS one-liners: `.cursor/rules/windows-powershell-auto.mdc`. Детали hit: `.cursor/rules/lean-ctx.mdc`.
