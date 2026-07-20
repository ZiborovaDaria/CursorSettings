# MCP Playbooks — 1C Cursor projects

Канон инструментов: `24-always-mcp-tool-router.mdc`. **Без** codegraph. **Без** WebFetch-spam (`/research-repo`, `ctx_url_read`).

Канон ИБ/версии — из **project context** / `.dev.env` / `mcp.json` текущего workspace (не копировать чужой HTTP чужого проекта).

## BSL locate → edit → verify

1. Locate: `bsl-atlas-*` или `code-index` (`search_function` / `code_grep` / `codesearch`).
2. Callers: `code-index` `get_callers` / `get_callees`.
3. Read XML/docs: lean-ctx `ctx_read`.
4. Edit: Serena после locate.
5. Verify: naparnik `check_1c_code` → при сдаче `/deploy_and_test`.

## Форма (managed)

1. Locate: atlas/code-index + form skills.
2. Rules: `1c-managed-forms-agent.mdc`.
3. Validate form skill.
4. UI smoke: screenshot/puppeteer только по явной UI-задаче.

## Запрос / производительность

1. `1c-query-optimization` + queries-performance agent.
2. Параметры, без конкатенации ввода.

## CFE patch

1. `&Перед` / `&После` / `&ИзменениеИКонтроль`.
2. `&Вместо` — только с явным OK.
3. Skills: `1c-cfe-*`.

## Runtime ИБ

1. `mcp-1c` — по project mcp.json.
2. OData: `1c-rest-mcp` только по явной OData-задаче.

## External GitHub / URL

1. `/research-repo`: uploads → `%TEMP%` clone / `gh api` tree → `ctx_read`.
2. Один URL: `ctx_url_read`.
3. Не серия `WebFetch`.

## Docs 1С

naparnik / platform-docs / v8std — не веб-fetch вместо MCP.
