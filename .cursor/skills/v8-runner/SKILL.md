---
name: v8-runner
description: Orchestrate 1C build, syntax checks, YAxUnit/Vanessa tests, dump, and launch via v8-runner CLI or MCP. Use when the user asks to build CFE, run tests, check syntax, dump config, or launch 1C client.
---

# v8-runner

## When to use

- Build or load CFE / main config into the infobase.
- Run syntax checks (`designer-modules`, `designer-config`, `edt`).
- Run YAxUnit or Vanessa Automation tests.
- Dump config to files or make `.cf`/`.cfe`/`.epf`/`.erf` artifacts.
- Launch 1C client (thin/thick/designer) or MCP-enabled client.

## When not to use

- Locate BSL code — use `bsl-atlas` / `litecode` / `code-index` instead.
- Edit BSL/XML — use native edit after locate.
- OData queries — use `1c-rest-mcp` for explicit OData tasks.
- UI web e2e — use Playwright / `tests/web/`.

## Project config

Ensure `v8project.yaml` exists in the project root. Typical shape for UT25_85:

```yaml
workPath: build
execution_timeout: 300000
format: DESIGNER
builder: DESIGNER
infobase:
  connection: "File=C:\\Users\\Admin\\Documents\\1C\\UT25_85"
  user: Admin
  password: "1"
source-set:
  - name: main
    type: CONFIGURATION
    path: .
  - name: ВыгрузкаРТУСМаркировкойWB
    type: EXTENSION
    path: "Extent/ИмпортПро УТ/ВыгрузкаРТУСМаркировкойWB"
```

Keep machine-local paths and credentials in `v8project.local.yaml` (already in `.gitignore`).

## Common CLI commands

```bash
# Build all source-sets
v8-runner build

# Syntax check server modules
v8-runner syntax designer-modules --server

# YAxUnit tests
v8-runner test yaxunit all

# Vanessa Automation
v8-runner test va

# Launch MCP-enabled thin client
v8-runner launch mcp

# Dump main config
v8-runner dump --mode incremental
```

## MCP tools

When the `v8-runner` MCP server is enabled, prefer these tools over CLI shell calls:

- `build_project` — build configured source-sets.
- `run_all_tests` — YAxUnit or Vanessa (set `runner=vanessa`).
- `run_module_tests` — YAxUnit by module name.
- `check_syntax_designer_config` / `check_syntax_designer_modules` — syntax checks.
- `launch_app` — launch 1C client or MCP client.
- `dump_config` — dump config to files.

## Important notes

- The v8-runner binary path is `C:\CursorMCP\v8-runner-rust\v8-runner.exe` by convention. Adjust if built elsewhere.
- For `builder=IBCMD` or `format=EDT`, follow the `v8project.yaml` contract in the v8-runner docs.
- Do not hardcode project-suffixed atlas names (`bsl-atlas-ut25_85`) in shared rules — use `bsl-atlas`.
