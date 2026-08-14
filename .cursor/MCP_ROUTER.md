# MCP Router (project-agnostic)

Always-on: `global-05-always-mcp-tool-router.mdc`.  
Project overlay (ИБ, `repo` alias, `config_help` name): `01-*-project-context.mdc` + `.dev.env` + `mcp.json`.

```text
bsl-atlas     = Locate + verify_* + help.search   (URL → индекс текущего проекта)
litecode      = metadata graph / routines / call_graph
code-index    = fallback Locate + callers (repo=<project>) + docs (repo=docs)
Serena        = Edit после locate+consult
naparnik + v8std + syntax-helper = Verify / docs / стандарты
mcp-1c        = runtime ИБ
Hub + repo=docs = agent-lessons / content-patterns / bsp-api
UI e2e        = Playwright / 1c-web-test (не MCP browser)
```

## Роутер по задачам

| Намерение | Первый выбор | Второй выбор |
|---|---|---|
| BSL по имени | Atlas `search_function` → `read_function` | code-index / litecode `get_routines`+`get_routine_body` |
| BSL по смыслу | Atlas `codesearch` / `search_code_filtered` | litecode `find_routines_by_description` |
| Regex в BSL | Atlas `code_grep` | code-index `grep_code` / `grep_body` |
| Метаданные / реквизиты | Atlas `metadatasearch` → `get_object_details` | litecode `object_structure`/`get_children`; `mcp-1c` |
| Форма / СКД | Atlas `get_form_info` / `get_skd_info` | mcp-1c / litecode `get_form` |
| Callers / impact | Atlas `verify_call` | code-index `get_callers`/`get_callees`; litecode `get_call_graph` |
| Поле/тип | Atlas `verify_field` | litecode / mcp-1c |
| Справка платформы | `1c-syntax-helper`; Atlas `help.search`; naparnik `onec_help` | `mcp-1c.bsl_syntax_help` |
| Docs прикладной КФ | naparnik `config_help` | `its_help` → `fetch_its` |
| Стандарты / ACC / BSLLS | v8std | naparnik `review_1c_code` |
| Hub lessons / patterns | `consult-1c-shared-lessons` / `reuse-1c-shared-patterns` | code-index `repo=docs` |
| БСП API по смыслу | Hub dense: `Search-BspApiDense.py` (`qwen3-embedding:4b`) | FTS `bsp-api/summaries`; затем locate `Модуль.Имя` |
| Indexed docs (Hub) | code-index `search_text` / `grep_text` (`repo=docs`) | lean-ctx `ctx_read` |
| Правка BSL | Serena после locate+consult | — |
| XML / md / shell | lean-ctx `ctx_*` (hit: no `fresh`; Fn-ref; `full` only before edit; PS allowlist — см. playbooks) | native при jail |
| Runtime / запрос | mcp-1c `validate_query` / `execute_query` | rest-mcp только OData |
| Verify | `check_1c_code` → `review_1c_code` → `verify_*` / v8std | — |
| UI / web регресс | Playwright + `tests/web/` + skill `1c-web-test` | см. `tests/web/AGENT-PROMPT.md` |
| UI / web разведка | `getFormState` / optional `playwright-cli --headed` | не MCP screenshot/puppeteer; `@playwright/mcp` только approve |

## Конвейер «правильный код» (anti-hallucination)

```text
1. Hub KB: consult-1c-shared-lessons (+ reuse patterns если CFE/EPF/форма)
2. Locate типовой аналог: bsl-atlas / litecode / code-index
3. Структура объекта: get_object_details / object_structure (не угадывать реквизиты)
4. Impact: get_callers / get_call_graph / verify_call
5. Справка: syntax-helper / help.search / onec_help / config_help / v8std
6. Edit: Serena, минимальный diff; CFE: &Перед/&После/&ИзменениеИКонтроль
7. Verify: check_1c_code → review_1c_code → verify_field/verify_call
8. UI smoke: explore → `tests/web/*.exec.js` (DSL) → run; не puppeteer/screenshot MCP
```

## litecode

Один tool `search_metadata`, `query` = JSON с `"op"`:  
`browse`, `object_structure`, `get_children`, `get_form`, `get_routines`, `get_routine_body`, `get_call_graph`, `get_references`, `find_routines_by_description`, `resolve`, `get_subscriptions`, `get_access`.

## Запреты

- Не хардкодить `bsl-atlas-bp` / `bsl-atlas-ut25_85` в shared-правилах — только **`bsl-atlas`**.
- codegraph / dual-channel Grep / Serena-до-locate / mcp-on-demand spam.
- **Native locate BLOCKER** (см. `global-05`): Read/Grep/Glob на 1С-дереве без `MCP tried: …; fallback because: …`.
- **Anti-loop:** Grep→Read→Grep по Form.xml/UUID — заменить на `get_form` / `get_references`.
- Hot-debug spam Grep/Read вместо atlas → `read_function` → `ctx_read` lines (lesson `process-mcp-io-discipline`).
- MCP `screenshot` / `puppeteer-real-browser` — вне стека (замена: Playwright).
- `ctx_shell` BLOCKED по `$var` → переписать / `powershell -File script.ps1` / `lean-ctx allow $var`, не native Shell в обход.

## KPI

- `/mcp-audit` или `cursor-addons/install/Invoke-McpUsageAudit.ps1` — раз в неделю.
- Пороги по умолчанию: mcpShare≥40%, readMcp≥30%, grepMcp≥40%, shellMcp≥15%.
