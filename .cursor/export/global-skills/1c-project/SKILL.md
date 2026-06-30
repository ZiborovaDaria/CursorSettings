---
name: 1c-project
description: "Общий workflow 1С-проекта: Memory Bank, delivery type, MCP-first locate, реализация и verify. Контекст КФ — из workspace *-project skill."
---

# 1C Project Skill

Use for general 1C project work.

## Workflow

1. Read `AGENTS.md` if present.
2. Open workspace `*-project` skill if exists (`esti-project`, `bp-project`, `unf-project`, …).
3. Read Memory Bank for non-trivial tasks.
4. Determine delivery type (CFE, EPF, ERF, metadata, script, docs, query, test).
5. Use MCP-first locate before grep.
6. Write real BSL/XML/PowerShell when implementation is requested.
7. Verify and report.

## Main rules

- `1c-code-writing-agent.mdc`
- `1c-mcp-first-search-agent.mdc`
- `1c-testing-release-agent.mdc`

If workspace has `project-*-context-agent.mdc` or `project-*-mcp-router-agent.mdc` — load those too.
