# MCP-серверы проекта ЭСТИ: оптимальная маршрутизация

Источник: актуальные дескрипторы Cursor MCP. Этот файл описывает **как выбирать серверы**, а не заменяет `.cursor/mcp.json`.

Краткая инструкция: `.cursor/MCP_QUICK_START.md` · полная матрица: `.cursor/MCP_TOOLS_MATRIX.md`.

## Роли (v4, 2026-06)

Правила: `00-esti-core.mdc`, `03-mcp-locate.mdc`, `25-agent-bsl-atlas-esti.mdc`, `27-agent-litecode-esti.mdc`, `28-agent-role-rights-esti.mdc`.

**POWER:** Atlas + Litecode оба обязательны. **LITE:** только Litecode.

| Фаза | POWER | LITE |
|---|---|---|
| Locate BSL/метаданные | **bsl-atlas-esti** | **litecode** |
| Права ролей / граф | **litecode** `get_access` | **litecode** `get_access` |
| Locate fallback | **code-index** (`repo`: ESTI) | **code-index** |
| Locate метаданные (ИБ) | **mcp-1c** | **mcp-1c** |
| Understand | **lean-ctx** `ctx_callgraph` | **lean-ctx** |
| Edit | **Serena** | **Serena** |
| Verify | naparnik (`config_name=УНФ`), v8std | naparnik, v8std |

## Роутер по задачам

| Намерение | Первый выбор | Второй выбор | Когда НЕ использовать |
|---|---|---|---|
| Узнать конфигурацию/релиз | `mcp-1c.get_configuration_info` | `bsl-atlas-esti.stats` | Не спрашивать пользователя, если ИБ доступна |
| Найти объект метаданных | `bsl-atlas-esti.metadatasearch` | `mcp-1c.get_metadata_tree` | grep по XML |
| Структура объекта, реквизиты, ТЧ | `bsl-atlas-esti.get_object_details` | `mcp-1c.get_object_structure` | Object.xml целиком |
| Структура формы / СКД | `bsl-atlas-esti.get_form_info` / `get_skd_info` | `mcp-1c.get_form_structure` | Form.xml вслепую |
| Семантика («где проводится…») | `bsl-atlas-esti.codesearch` | `litecode.search_by_embedding` | grep по всей КФ |
| Точное имя процедуры | `bsl-atlas-esti.search_function` | `code-index.grep_body` | Serena первым |
| Тело процедуры + контекст | `bsl-atlas-esti.read_function` | `code-index.get_function` | `ctx_read` всего модуля |
| Regex в BSL | `bsl-atlas-esti.code_grep` | `code-index.grep_body` | — |
| Права роли на объект | `litecode` `get_access` | atlas `metadatasearch` | grep по Roles/ |
| Граф ссылок объектов (1С) | `litecode` `get_references` | `code-index.get_data_links` | — |
| Callers/callees | `lean-ctx.ctx_callgraph` | Serena `find_referencing_symbols` | codegraph (нет BSL) |
| Blast radius перед правкой | `lean-ctx.ctx_impact` | Serena `find_referencing_symbols` | — |
| Точечная правка кода | `serena.replace_symbol_body` | native Edit | — |
| Чтение файлов/XML | `lean-ctx.ctx_read` | native Read | большие BSL целиком |
| Запрос 1С | `mcp-1c.validate_query` → `execute_query` | `1c-rest-mcp.odata_query` | непроверенный запрос |
| OData / живые данные | `1c-rest-mcp` | `mcp-1c.execute_query` | изменение без запроса |
| Синтаксис платформы | `1c-syntax-helper.get_syntax_info` | `naparnik.onec_help` | угадывание API |
| УНФ/БСП/ITS | `naparnik.config_help(УНФ)` → `fetch_its` | `its_help` | общая веб-справка |
| Стандарты | `v8std_search` → `v8std_get_related` | `review_1c_code` | — |
| Веб-клиент 1С | `puppeteer.get_content` | `screenshot.login-and-wait` | — |

## Цепочки по умолчанию

### Маленькая BSL-правка (CFE)
`bsl-atlas-esti.search_function` → `read_function` → Serena `find_symbol(body=true)` → `ctx_impact` → `replace_symbol_body` → `check_1c_code` → `ctx_read(diff)`.

### Новая/изменённая форма расширения
`bsl-atlas-esti.get_form_info` → `mcp-1c.get_form_structure` → правка XML/BSL → `puppeteer` для веб-клиента.

### Запрос или отчёт
`mcp-1c.get_object_structure` → `validate_query` → `execute_query(limit=10)` → `check_1c_code(performance)` → `v8std`.

### Архитектура / влияние
`bsl-atlas-esti.codesearch` → `read_function` → `ctx_callgraph` → решение CFE → arch-reviewer.

## bsl-atlas-esti: инструменты

Документация: https://github.com/Arman-Kudaibergenov/bsl-atlas

| Инструмент | Назначение |
|---|---|
| `search_function` | Процедура/функция по имени |
| `read_function` | Тело + контекст |
| `get_module_functions` | Список символов модуля |
| `get_function_context` | Граф вызовов функции |
| `metadatasearch` | Объекты метаданных |
| `get_object_details` | Реквизиты, ТЧ, регистры |
| `get_form_info` | Форма из индекса |
| `get_skd_info` | СКД из индекса |
| `codesearch` | Семантика (нужен ChromaDB 100%) |
| `helpsearch` | Справка/knowledge слой |
| `code_grep` | Regex по BSL |
| `verify_call` / `verify_field` | Проверка вызова/поля |
| `triggers_on_write` | Кто пишет в регистр |
| `reindex` / `reindex_changed` | После выгрузки |
| `stats` | Статистика индекса |
| `repomap` | Карта модулей |

Статус: `.cursor/scripts/Get-BslAtlasIndexStatus-ESTI.ps1`

## code-index (bsl-indexer): доп. 1С-инструменты

| Инструмент | Назначение |
|---|---|
| `get_object_structure` | Структура из XML |
| `get_form_handlers` | Обработчики формы |
| `get_data_links` | Граф ссылок |
| `find_data_path` | Цепочка ссылок |
| `get_register_writers` | Писатели регистра |
| `grep_body` | Поиск в телах функций |

Во всех вызовах: `repo`: **ESTI**.

## lean-ctx (user global)

| Инструмент | Назначение |
|---|---|
| `ctx_overview(task)` | Карта проекта в начале сессии |
| `ctx_knowledge` | Память между сессиями (L1 episodic) |
| `ctx_callgraph` | callers/callees/trace |
| `ctx_impact` | Blast radius |
| `ctx_semantic_search` | Поиск по смыслу в репо |

### ctx_knowledge — remember / recall

| action | Когда |
|---|---|
| `recall` | Перед fix нетривиальной ошибки; query = текст ошибки, объект, процедура |
| `remember` | После успешного fix; key, value, trigger, resolution (gotcha) |
| `search` | Обзор накопленных фактов по теме |

Правило конвейера: `33-agent-error-learning-pipeline.mdc`. Корневой `memory.md`.

## Memory / error learning (слои)

| Слой | Хранилище | Инструмент / путь |
|---|---|---|
| L0 Task | Memory Bank | `memory-bank/tasks.md`, `reflection/`, `archive/` |
| L1 Episodic | lean-ctx | `ctx_knowledge` remember/recall |
| L2 Project | Serena | `read_memory` / `write_memory` → `.serena/memories/`; вход `mem:core` |
| L3 Rules | Cursor | `.cursor/rules/*.mdc` при ≥2 повторах или critical |

| Намерение | Первый выбор | Второй выбор |
|---|---|---|
| Урок по прошлой ошибке | `ctx_knowledge recall` | Serena `read_memory pitfalls/cfe_bsl` |
| Сохранить gotcha после fix | `ctx_knowledge remember` | — |
| Устойчивый инвариант ESTI/CFE | Serena `write_memory` | дополнение `pitfalls/cfe_bsl` |
| Ретроспектива задачи | `memory-bank/reflection/` | команда `reflect-lesson` |
| Promote в правило | skill `create-rule` | только ≥2 повтора или critical |

**Serena memories (проект):** `core`, `project_overview`, `code_style_and_conventions`, `pitfalls/cfe_bsl`, `task_completion_checklist`, `suggested_commands`.

## 1c-naparnik: полный набор

`ask_1c_ai`, `check_1c_code`, `review_1c_code`, `modify_1c_code`, `rewrite_1c_code`, `explain_1c_syntax`, `config_help`, `its_help`, `fetch_its`, `onec_help`, `search_1c_documentation`, `diff_1c_documentation_versions`.

## Запрещённые устаревшие имена (вне bsl-atlas)

Не ссылаться как на MCP-сервер: `get_metadata_details`, `templatesearch`, `business_search`, `graph_dependencies`, `get_method_call_hierarchy`, `get_module_structure`, `search_forms`, `verify_xml`, `syntaxcheck`.

Для **bsl-atlas-esti** имена `metadatasearch`, `codesearch`, `search_function` — **корректны** (см. `25-agent-bsl-atlas-esti.mdc`).

## Замены

| Устаревшее | Замена |
|---|---|
| `get_metadata_details` | `bsl-atlas-esti.get_object_details` / `mcp-1c.get_object_structure` |
| `codesearch` (без Atlas) | `bsl-atlas-esti.codesearch` / `code-index.grep_body` |
| `codegraph_context/trace` | `lean-ctx.ctx_callgraph` / `codegraph_explore` (не для BSL) |
| `get_module_structure` | `get_module_functions` / `get_file_summary` |
