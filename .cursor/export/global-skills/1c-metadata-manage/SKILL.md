---
name: 1c-metadata-manage
description: "1C metadata management — create, edit, validate, and remove configuration objects (catalogs, documents, registers, enums), managed forms, data composition schemas (SKD), spreadsheet layouts (MXL), roles, external processors (EPF/ERF), extensions (CFE), configurations (CF), databases, subsystems, command interfaces, templates. Also: execute code or queries in a 1C database, read data, validate queries, retrieve event log errors. Use when working with 1C metadata structure or when interacting with a live 1C database."
---

# 1C Metadata Manage — Skill Dispatch

Use this skill when the task involves **1C metadata structure** (creating, editing, validating, or removing configuration objects, forms, reports, layouts, roles, extensions, or databases) or **live 1C database interaction** (executing code, running queries, reading data, checking the event log).

## Authentication First (Mandatory)

Before using 1C MCP tools, ensure authorization is valid:

- For local DB MCP (`user-mcp-1c`), read `infobasesettings.md`: проект **SB** — без аутентификации; иначе логин/пароль из настроек.
- For REST MCP (`user-1c-rest-mcp`), verify `ONEC_BASE_URL`; логин/пароль — только если включены в публикации (см. `infobasesettings.md`).
- If the first call returns `401`, stop data operations and fix connection/auth config first.

## Project MCP: `user-code-index` and `user-v8std`

Use when Cursor exposes these servers (see **`@rules/mcp-tools.mdc`**).

### `user-code-index` (local daemon)

- **When:** huge on-disk trees (100k+ files), full configuration dumps, finding **callers/callees**, FTS over **BSL** modules, regex search with repo-scoped globs — faster than blind workspace grep.
- **Prerequisite:** `code-index.exe daemon run` (or equivalent); verify with **`health`** / **`get_stats`**.
- **Parameter `repo`:** alias from code-index config (`daemon.toml`). Always pass **`path_glob`** or **`language`** for expensive `grep_code` to avoid full-scan.
- **Typical globs for 1C:** `**/Documents/**/*.bsl`, `**/CommonModules/**`, `**/DataProcessors/**`, etc.

### `user-v8std` (v8std.ru)

- **When:** development standards and diagnostics as published on **v8std.ru**, linking BSLLS/ACC/EDT codes to standard text; use **`v8std_search`** → **`v8std_get_page`**, or **`v8std_explain_diagnostics`** / **`v8std_explain_snippet`** for targeted input.
- **Privacy:** public service — do **not** send proprietary source; for closed code use local MCP per [v8std support](https://v8std.ru/support/#local-mcp).
- **Complement, not replace:** platform docs — `search_1c_documentation` / `onec_help`; ITS methodology — `its_help` → `fetch_its`; code quality pass — `check_1c_code` / `review_1c_code` (`user-1c-naparnik`).

## Dispatch Strategy

Determine task complexity, then choose the execution mode:

### Direct execution — simple / read-only tasks

Use when the task is a **single lightweight query**: checking metadata info, a quick lookup, one validation call. In this case identify the task domain from the table below, read the corresponding file, and follow its instructions directly.

### Subagent delegation — complex / mutation tasks

Политика «только расширение (CFE), опора на типовой код, субагенты и MCP»: **`@rules/1c-extension-typical-subagents-mcp.mdc`**.

Delegate to the **`/metadata-manager`** subagent (defined in `@agents/metadata-manager.md`) when **any** of the following is true:

- The task **creates, scaffolds, or compiles** metadata (objects, forms, SKD, MXL, roles, EPF, CF, CFE, databases)
- The task **edits multiple files** or **spans multiple domains**
- The task involves a **multi-step workflow** (create → edit → validate → fix → re-validate)
- The task requires **reading large domain docs** (forms, meta-manage, SKD, MXL, roles, EPF, DB — each 200–800 lines)

The subagent already knows how to read the skill docs, execute PowerShell scripts, and validate results. Provide it with the full task description including object names, attributes, types, and any business context from the conversation.

## Task Domain Table

| Task Domain | Keywords | File |
|---|---|---|
| Metadata objects — create, edit, analyze, remove, validate | catalog, document, register, enum, constant, module, attribute, tabular section | [meta-manage.md](docs/meta-manage.md) |
| Managed forms — design, create, edit, analyze, validate | form, Form.xml, UI, elements, commands, events | [form-manage.md](docs/form-manage.md) |
| Data Composition Schema (DCS/SKD) — create, edit, analyze, validate | report, DCS, SKD, data composition, data set, query | [skd-manage.md](docs/skd-manage.md) |
| Spreadsheet documents (MXL) — create, decompile, analyze, validate | MXL, spreadsheet, template, print form, layout | [mxl-manage.md](docs/mxl-manage.md) |
| Roles and access rights — create, analyze, validate | role, rights, RLS, access, permissions | [role-manage.md](docs/role-manage.md) |
| External processors/reports (EPF/ERF) — scaffold, build, dump, validate | EPF, ERF, data processor, external report, build, dump | [epf-manage.md](docs/epf-manage.md) |
| BSP/SSL registration and commands | BSP, SSL, ExternalDataProcessorInfo, registration, command | [bsp-manage.md](docs/bsp-manage.md) |
| Configuration (CF) — create, edit, analyze, validate | configuration, Configuration.xml, CF | [cf-manage.md](docs/cf-manage.md) |
| Extensions (CFE) — create, borrow, diff, patch, validate, load hang recovery | extension, CFE, borrow, interceptor, patch, LoadConfigFromFiles, 100% | [cfe-manage.md](docs/cfe-manage.md), [cfe-load-hang-recovery](../cfe-load-hang-recovery/SKILL.md) |
| Databases — registry, create, run, load, dump | database, infobase, .v8-project.json, create DB, run 1C | [db-manage.md](docs/db-manage.md) |
| Subsystems — create, edit, analyze, validate | subsystem, command interface, ChildObjects | [subsystem-manage.md](docs/subsystem-manage.md) |
| Command interface — edit, validate | CommandInterface.xml, commands visibility, groups | [interface-manage.md](docs/interface-manage.md) |
| Templates/layouts management — add, remove | template, layout, SpreadsheetDocument, HTML template | [template-manage.md](docs/template-manage.md) |
| Help pages — add, manage | help, built-in help, documentation | [help-manage.md](docs/help-manage.md) |
| SSL/BSP subsystems patterns | SSL patterns, standard subsystems, BSP events | [ssl-patterns.md](docs/ssl-patterns.md) |
| Query optimization | query, temporary table, join, DCS optimization | [query-optimization.md](docs/query-optimization.md) |
| 1C data tools — execute code, queries, diagnostics | validate query, execute query, metadata tree, object/form structure, event log, OData entities, OData queries | [data-tools.md](docs/data-tools.md) |

**If the task spans multiple domains**, the subagent will read all relevant docs automatically (or read each one directly for simple tasks).

## Practical KA 2.5 workflow (validated)

Use this sequence for tasks where you must **update an extension in DB** and **create/post test documents** quickly.

### A. Extension update in infobase (works)

1. Load extension files into existing extension metadata:
   - `1cv8.exe DESIGNER /F "<path_to_ib>" /N Admin /P 1 /LoadConfigFromFiles "<project_extension_path>" -Extension "<extension_name>" /Out "<log_path>"`
2. Apply DB update for extension:
   - `1cv8.exe DESIGNER /F "<path_to_ib>" /N Admin /P 1 /UpdateDBCfg -Extension "<extension_name>" /Out "<log_path>"`

Validated on KA 2.5.25.85 for extension `ТипЗаказаКлиента` from `Extentions/TZK`.

### B. Document chain creation/posting (works)

For robust automation, prefer **COMConnector** over fragile UI scripting:

1. Ensure COM connector is registered (one-time on machine):
   - `regsvr32 "<platform_bin>\\comcntr.dll"`
2. Use PowerShell + `V85.COMConnector` to connect and create documents.
3. Create/post chain via script (recommended to keep in `build/`):
   - create `ЗаказКлиента` (`ТипЗаказа = Предзаказ`)
   - create linked `ЗаказПоставщику`
   - simulate partial supplier confirmation
   - post documents and verify resulting states.

### C. Known non-working path and workaround

- Direct startup with `1cv8.exe ENTERPRISE /Execute <epf>` can fail in KA2 because start page intercepts focus and script flow is not executed reliably.
- Workaround: run server-side logic through `V85.COMConnector` scripts instead of `/Execute`.
