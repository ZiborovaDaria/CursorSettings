# RULES_INDEX — final v3

Карта правил, команд, навыков и MCP для 1С/ESTI workspace.

## Always-on

| Rule | Purpose |
|---|---|
| `global-00-always-1c-memory-bank-router.mdc` | главный роутер 1С + Memory Bank + обычный Agent Mode |
| `global-01-always-safe-scope.mdc` | безопасность, base config, secrets, ambiguity, CFE blocker |
| `global-02-always-skill-router.mdc` | маршрутизация к существующим skills/rules |
| `global-03-always-memory-bank-paths.mdc` | канонические пути Memory Bank |
| `global-04-always-error-learning-trigger.mdc` | короткий trigger error-learning |

## General 1C rules

| Scenario | Rule |
|---|---|
| Write/edit BSL | `1c-code-writing-agent.mdc` |
| BSL standards | `1c-bsl-standards-auto.mdc` |
| CFE | `1c-cfe-extensions-agent.mdc` |
| EPF/ERF | `1c-epf-erf-agent.mdc` |
| Managed forms | `1c-managed-forms-agent.mdc` |
| Metadata XML | `1c-metadata-xml-auto.mdc` |
| Module structure | `1c-module-structure-agent.mdc` |
| Queries | `1c-queries-performance-agent.mdc` |
| Locks/transactions | `1c-locks-transactions-agent.mdc` |
| Debug/verification | `1c-debug-verification-agent.mdc` |
| Testing/release | `1c-testing-release-agent.mdc` |
| YAxUnit | `1c-yaxunit-agent.mdc` |
| Windows PowerShell | `windows-powershell-auto.mdc` |

## ESTI project-specific

| Scenario | Rule |
|---|---|
| Project context | `project-esti-context-agent.mdc` |
| MCP POWER/LITE routing | `project-esti-mcp-router-agent.mdc` |
| Tooling playbooks | `project-esti-tooling-playbooks-agent.mdc` |
| Single 1C launch | `project-esti-single-1c-launch-agent.mdc` |
| Orchestrator JSON | `project-esti-orchestrator-bridge-agent.mdc` |
| Error learning | `project-esti-error-learning-agent.mdc` |

## Commands

| Command | Purpose |
|---|---|
| `/van` | task entry and level classification |
| `/plan` | plan |
| `/creative` | architecture/decision phase |
| `/implement` | implementation, compatible with Supercode IMPLEMENT |
| `/build` | alias for `/implement` |
| `/reflect` | task reflection |
| `/archive` | close/archive task |
| `/doctor` | self-check rules/memory/env |
| `getconfigfiles` | export/update config files |
| `deploy_and_test` | load/check/test in 1C |
| `capture-error` | error recall/fix pipeline |
| `reflect-lesson` | store reusable lesson |
| `handoff` | session/PC/agent transfer |
| `check-uuid` | metadata UUID/reference check |
| `caveman` | short engineering answer mode |

## Skills

| Scope | Path | Examples |
|---|---|---|
| **Project** (конфиг) | `.cursor/skills/<name>/SKILL.md` | `esti-project`, `mcp-1c-tools`, `orchestrator-bridge` |
| **Global** (общие 1С) | `~/.cursor/skills/<name>/SKILL.md` | `1c-cfe-full-cycle`, `1c-project`, `memory-bank-1c`, `handoff` |

Router: project first, then global (`global-02-always-skill-router.mdc`).

## Legacy policy

Old duplicate rules may be kept only as `.mdc.off`. Active `.mdc` duplicates can conflict with v3.
