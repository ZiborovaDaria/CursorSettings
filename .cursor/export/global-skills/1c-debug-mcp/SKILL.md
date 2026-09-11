---
name: 1c-debug-mcp
description: Debug BSL code interactively via the 1C debug server (dbgs.exe) and MCP. Use when investigating runtime errors, setting breakpoints, inspecting variables, or evaluating BSL expressions.
---

# 1c-debug-mcp

## Prerequisites

1. Build or download the MCP binary: `C:\CursorMCP\1c-debug-mcp\go\dist\1c-debug-mcp.exe`.
2. Start the 1C debug server:
   ```cmd
   dbgs.exe --port=1550 --addr=localhost
   ```
3. Enable the `1c-debug` MCP server in `.cursor/mcp.optional.json` (it is disabled by default).

## Typical debug workflow

1. **Attach**
   ```
   mcp_1c_debug_attach()
   ```

2. **Set breakpoints or pause**
   ```
   mcp_1c_debug_set_breakpoints(
     moduleName="ОбщегоНазначения",
     moduleType="CommonModule",
     lines=[42]
   )
   ```
   Or use `pause` for a global stop on next line.

3. **Wait for stop**
   ```
   stop = mcp_1c_debug_wait_for_stop()
   ```

4. **Inspect**
   ```
   mcp_1c_debug_get_variables(targetId=stop.targetId)
   mcp_1c_debug_get_call_stack(targetId=stop.targetId)
   mcp_1c_debug_evaluate(
     targetId=stop.targetId,
     expression="ТекущаяДата()"
   )
   ```

5. **Continue / step / detach**
   ```
   mcp_1c_debug_continue(targetId=stop.targetId)
   mcp_1c_debug_step_in(targetId=stop.targetId)
   mcp_1c_debug_detach()
   ```

## Extension breakpoints

For CFE modules, always pass `extensionName`:

```
mcp_1c_debug_set_breakpoints(
  moduleName="_ДемоЗаказПокупателя",
  moduleType="ObjectModule",
  extensionName="_МоёРасширение",
  lines=[4]
)
```

## EPF limitation

Breakpoints do not work for external processing modules (EPF) due to 1C debug protocol limits. Use `pause` + step-by-step execution instead.

## Configuration env

Key variables in `mcp.optional.json`:

- `ONEC_DEBUG_URL` — `http://localhost:1550`
- `ONEC_INFOBASE_ALIAS` — alias or infobase name
- `ONEC_CF_PATH` — path to main config sources
- `ONEC_CFE_PATHS` — semicolon-separated extension source paths
- `ONEC_EPF_PATHS` — semicolon-separated EPF paths
- `ONEC_LOG_FILE` — optional log file
