# MCP Tools Matrix — ЭСТИ

Полный справочник инструментов. Роутер «что выбрать первым»: `MCP_ROUTER_ESTI.md`.

**Профиль POWER:** Atlas + Litecode оба обязательны. **LITE:** только Litecode + code-index.

---

## bsl-atlas-esti (18 tools)

| Tool | Назначение | Первый выбор | Не использовать для |
|---|---|---|---|
| `search_function` | Процедура по имени | ✓ имя известно | семантики |
| `read_function` | Тело + контекст | после search | всего модуля |
| `get_module_functions` | Список символов | состав модуля | — |
| `get_function_context` | Граф вызовов функции | — | полного callgraph |
| `metadatasearch` | Объекты метаданных | ✓ объект | прав ролей |
| `get_object_details` | Реквизиты, ТЧ | структура | Rights.xml |
| `get_form_info` | Форма | форма из индекса | — |
| `get_skd_info` | СКД | отчёт/СКД | — |
| `codesearch` | Семантика BSL | смысл неизвестен | точного имени |
| `helpsearch` | Справка/knowledge | — | — |
| `code_grep` | Regex BSL | паттерн | — |
| `verify_call` | Проверка вызова | API verify | — |
| `verify_field` | Проверка поля | API verify | — |
| `triggers_on_write` | Писатели регистра | движения | — |
| `reindex` / `reindex_changed` | Переиндексация | после выгрузки | — |
| `stats` | Статистика | health | — |
| `repomap` | Карта модулей | обзор | — |

---

## litecode (2 MCP tools → 14 op)

| MCP Tool | op (в `search_metadata`) | Назначение | Первый выбор |
|---|---|---|---|
| `search_metadata` | `browse` | Категории метаданных | обзор |
| | `object_structure` | Реквизиты объекта | структура |
| | `get_children` | Дочерние | иерархия |
| | `get_form` | Форма | форма |
| | `get_routines` | Процедуры модуля | BSL locate (LITE) |
| | `get_routine_body` | Тело | после get_routines |
| | `get_call_graph` | Вызовы BSL | callgraph |
| | `get_references` | USED_IN / MOVEMENTS | граф ссылок |
| | **`get_access`** | **Права ролей** | **✓ роли/права** |
| | `get_http_service` | HTTP-сервисы | интеграции |
| | `resolve` | GUID → объект | — |
| | `find_routines_by_description` | По описанию | семантика (fast) |
| `search_by_embedding` | — | Семантика ONNX | смысл (full) |

---

## Права ролей (только Litecode + Atlas locate)

| Задача | 1-й | 2-й | Не использовать |
|---|---|---|---|
| Права роли на объект | `litecode` `get_access` | `ctx_read` Rights.xml | grep по Roles/ |
| Роли с доступом к объекту | `get_access(target=…)` | `metadatasearch` | — |
| BSL модуля роли (RLS) | `search_function` | `read_function` | — |
| Новая роль CFE | `1c-role-compile` | `get_access` verify | — |

`LOAD_ROLE_RIGHTS=true` обязателен. Правило: `28-agent-role-rights-esti.mdc`.

---

## Atlas vs Litecode — покрытие

| Домен | Atlas | Litecode |
|---|---|---|
| Процедура по имени | `search_function` | `get_routines` |
| Семантика BSL | `codesearch` | `search_by_embedding` |
| Метаданные | `get_object_details` | `object_structure` |
| Форма | `get_form_info` | `get_form` |
| СКД | `get_skd_info` | — |
| **Права ролей** | locate роли | **`get_access`** |
| Ссылки объектов | — | `get_references` |
| Движения регистров | `triggers_on_write` | `get_references` movements |
| HTTP-сервисы | — | `get_http_service` |
| Проверка вызова | `verify_call`, `verify_field` | — |
| GUID | — | `resolve` |

---

## code-index / bsl-indexer (ESTI)

| Tool | Назначение |
|---|---|
| `health` | Статус daemon |
| `get_stats` | Статистика (repo: ESTI) |
| `get_function` | Функция по имени |
| `grep_body` / `grep_code` | Поиск в BSL |
| `get_file_summary` | Сводка файла |
| `get_object_structure` | Структура из XML |
| `get_form_handlers` | Обработчики формы |
| `get_data_links` | Граф ссылок данных |
| `find_data_path` | Цепочка ссылок |
| `get_register_writers` | Писатели регистра |
| `find_path_bsl` | Путь в BSL |
| `search_terms` | Термины |

Fallback при недоступности Atlas/Litecode. `repo`: **ESTI**.

---

## mcp-1c

`get_configuration_info`, `get_metadata_tree`, `get_object_structure`, `get_form_structure`, `validate_query`, `execute_query`, `create_document`, … (HTTP-сервис расширения MCP_HTTPService).

---

## 1c-rest-mcp

`list_entities`, `odata_query`, `get_entity_metadata`, …

---

## serena (22 tools)

`find_symbol`, `replace_symbol_body`, `replace_content`, `find_referencing_symbols`, `get_symbols_overview`, `search_for_pattern`, … — **только после locate**.

---

## lean-ctx (23 tools)

`ctx_read`, `ctx_search`, `ctx_shell`, `ctx_tree`, `ctx_callgraph`, `ctx_impact`, `ctx_semantic_search`, `ctx_overview`, `ctx_knowledge`, …

---

## 1c-naparnik (12 tools)

`check_1c_code`, `review_1c_code`, `config_help`, `fetch_its`, `its_help`, `onec_help`, `search_1c_documentation`, `diff_1c_documentation_versions`, `modify_1c_code`, `rewrite_1c_code`, `explain_1c_syntax`, `ask_1c_ai`.

---

## v8std (5 tools)

`v8std_search`, `v8std_get_page`, `v8std_get_related`, `v8std_explain_snippet`, `v8std_explain_diagnostics`.

---

## 1c-syntax-helper (5 tools)

`get_syntax_info`, …

---

## puppeteer-real-browser (11 tools)

Веб-клиент 1С — по задаче UI.

---

## screenshot (5 tools)

`login-and-wait`, … — по задаче.

---

## codegraph (8 tools) — **не для BSL ЭСТИ**

`codegraph_explore`, `codegraph_impact`, … — XML/TS; на POWER/LITE для BSL не использовать.

---

## Итого

| Сервер | Tools (оценка) |
|---|---|
| bsl-atlas-esti | 18 |
| litecode | 2 (+ 14 op) |
| code-index | 12+ |
| serena | 22 |
| lean-ctx | 23 |
| naparnik | 12 |
| v8std | 5 |
| mcp-1c | 10+ |
| 1c-rest-mcp | 5+ |
| syntax-helper | 5 |
| puppeteer | 11 |
| screenshot | 5 |
| codegraph | 8 |
| **Сумма** | **~114+** |
