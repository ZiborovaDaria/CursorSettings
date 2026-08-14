# MCP Setup (project-agnostic)

Подключение: `.cursor/mcp.json` (project-local URL/алиасы).  
Выбор инструментов: `.cursor/MCP_ROUTER.md` + `global-05-always-mcp-tool-router.mdc`.  
ИБ/версия/префикс: `01-*-project-context.mdc`, `.dev.env`, `infobasesettings.md`.

## Серверы (логические имена для KB sync)

| Сервер в mcp.json | Назначение | Ключевые tools |
|---|---|---|
| **`bsl-atlas`** | Primary Locate (HTTP URL → индекс **этого** проекта) | `search_function`, `read_function`, `code_grep`, `codesearch`, `metadatasearch`, `get_object_details`, `get_form_info`, `get_skd_info`, `verify_call`, `verify_field`, `help.search`, `stats` |
| **`litecode`** | Metadata graph + BSL | `search_metadata` + JSON `"op"` |
| **`code-index`** | Индекс кода + Hub docs | code: `repo`=<project alias>; docs: `repo=docs` → `search_text`/`grep_text` |
| **`serena`** | Edit после locate | `find_symbol`, `replace_symbol_body`, `replace_content`, … |
| **`mcp-1c`** | Живая ИБ | `get_configuration_info`, `get_object_structure`, `get_form_structure`, `validate_query`, `execute_query`, `bsl_syntax_help` |
| **`1c-rest-mcp`** | OData | только явная OData-задача |
| **`1c-naparnik`** | Docs КФ/ITS/платформа + verify | `config_help`, `its_help`, `onec_help`, `check_1c_code`, `review_1c_code`, `explain_1c_syntax` |
| **`1c-syntax-helper`** | Справка синтаксиса | `get_syntax_info`, `list_object_members`, `search_by_context`, … |
| **`v8std`** | Стандарты | `v8std_search`, `v8std_explain_snippet`, `v8std_explain_diagnostics`, … |

## Не в mcp.json (намеренно)

| Было | Замена |
|---|---|
| `puppeteer-real-browser` | Playwright + skill `1c-web-test` + `tests/web/INSTALL.md` |
| `screenshot` | то же |
| project-suffixed atlas (`bsl-atlas-ut25_85`, `bsl-atlas-bp`) | единое имя **`bsl-atlas`**; URL в mcp.json смотрит на порт/индекс проекта |

## Пользовательские MCP

| Сервер | Назначение |
|---|---|
| `user-lean-ctx` | XML/docs/diff/shell: `ctx_read`, `ctx_search`, `ctx_tree`, `ctx_shell`, `ctx_url_read` |
| `user-mcp-on-demand` | не для обычного locate/verify |

**Не в роутере:** `user-codegraph`.

## code-index: два репо

В `mcp.json` обычно:

```text
--path <PROJECT_ALIAS>=${workspaceFolder}
--path docs=C:\1c-shared-patterns
```

| repo | Что искать |
|---|---|
| `<PROJECT_ALIAS>` из project ctx (напр. `UT25_85`) | BSL, метаданные выгрузки |
| `docs` | Hub: agent-lessons, content-patterns, playbooks |

В daemon.toml должен быть `[[paths]]` с `alias = "docs"` на `C:\1c-shared-patterns` (или путь добавлен через `--path` при serve).

## Atlas

Имя MCP всегда **`bsl-atlas`**. Контейнер/порт — project infra (см. project ctx).  
Down → сразу code-index + litecode, без Grep по всей КФ.

## Docs / KB stack (для качества кода)

1. Hub lessons: `C:\1c-shared-patterns\playbooks\agent-lessons\`
2. Patterns: `...\content-patterns\`
3. code-index `repo=docs`
4. Atlas `help.search`
5. naparnik + syntax-helper + v8std

## Устаревшие имена

| Было | Сейчас |
|---|---|
| `bsl-atlas-ut25_85` / `bsl-atlas-bp` / `bsl-atlas-*` в правилах | `bsl-atlas` |
| `MCP_ROUTER_UT.md` / `MCP_SETUP_UT.md` | `MCP_ROUTER.md` / `MCP_SETUP.md` |
| litecode `search_by_embedding` | `search_metadata` + `find_routines_by_description` |
| MCP screenshot / puppeteer | Playwright / `1c-web-test` |
