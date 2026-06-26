# MCP-серверы проекта ЭСТИ (2.2.5.90 / УНФ 3.0.13.342)

Источник подключения: `.cursor/mcp.json`. Роутинг: `.cursor/MCP_ROUTER_ESTI.md`. **Краткая инструкция:** `.cursor/MCP_QUICK_START.md`.

## Информационная база

См. `infobasesettings.md` (локально, не коммитить):

| Параметр | Значение |
|---|---|
| Файловая ИБ | `C:\Users\Admin\Documents\ESTI` |
| HTTP | `http://localhost/ESTI` |
| Пользователь | Admin |
| Пароль | 1 |

## Проектные серверы (`.cursor/mcp.json`)

| Сервер | Порт/тип | Назначение | Ключевые инструменты |
|---|---|---|---|
| `bsl-atlas-esti` | :8008 http | **Locate** BSL/метаданные по выгрузке | `search_function`, `codesearch`, `metadatasearch`, `read_function`, `get_object_details` |
| `mcp-1c` | stdio→HTTP | Живая ИБ: метаданные, запросы | `get_configuration_info`, `get_metadata_tree`, `validate_query`, `execute_query` |
| `1c-rest-mcp` | stdio→OData | Живые данные ИБ | `odata_query`, `get_documents`, `get_catalogs` |
| `code-index` | stdio (`bsl-indexer`) | Fallback locate + 1С-граф | `grep_body`, `get_data_links`, `get_object_structure`, `repo`: **ESTI** |
| `serena` | stdio | **Edit** BSL | `find_symbol`, `replace_symbol_body`, `rename_symbol` |
| `litecode` | :6004 sse | Граф метаданных Memgraph (если запущен) | `search_metadata`, `search_by_embedding` |
| `1c-naparnik` | :8007 | УНФ/ITS/проверка BSL | `config_help`, `check_1c_code`, `fetch_its` |
| `1c-syntax-helper` | :8000 | Справка платформы | `get_syntax_info`, `find_1c_help` |
| `v8std` | https | Стандарты 1С | `v8std_search`, `v8std_get_related` |
| `puppeteer-real-browser` | npx | Веб-клиент 1С | `navigate`, `get_content`, `click` |
| `screenshot` | node | Скриншоты + login-flow | `login-and-wait`, `screenshot-page` |

## Пользовательские MCP (глобально, `~/.cursor/mcp.json`)

| Сервер | Назначение |
|---|---|
| `lean-ctx` | `ctx_read`, `ctx_search`, `ctx_callgraph`, `ctx_impact`, `ctx_knowledge` |
| `codegraph` | Только для не-BSL (XML слабо); для BSL — Atlas + lean-ctx |
| `mcp-on-demand` | `search_tools` → `use_tool` (fallback) |

## bsl-atlas-esti

- Контейнер: `bsl-atlas-esti` (Docker)
- Индекс: `C:\bsl-atlas-indexes\ESTI`
- Исходники: `C:\Cursor\ESTI`
- Статус: `powershell -File .cursor/scripts/Get-BslAtlasIndexStatus-ESTI.ps1`
- Документация: https://github.com/Arman-Kudaibergenov/bsl-atlas
- Правило агента: `25-agent-bsl-atlas-esti.mdc`

## code-index (bsl-indexer)

Бинарник: `bsl-indexer.exe` (не `code-index.exe`). Алиас `ESTI` = `${workspaceFolder}`.

Проверка: tool `health`, `get_stats`.

## mcp-1c

Exe: `C:\CursorMCP\mcp-1c\mcp-1c.exe` → `http://localhost/ESTI/hs/mcp-1c`.

Тест: `python C:\AI_AGENT\scripts\test_esti_mcp.py`

## 1c-rest-mcp

После первого запуска при ошибке auth: `.cursor/scripts/patch-1c-rest-mcp-noauth.ps1`

## Запуск 1С

DESIGNER/ENTERPRISE: `/N Admin /P 1`. Правило: `21-agent-single-1c-launch.mdc`.
