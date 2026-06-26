# RULES_INDEX — ESTI

Карта правил, навыков и MCP. Заменяет устаревший `README_1C8_OPTIMIZED.md`.

**Установка на новом ПК:** [INSTALL_OTHER_DEVICE.md](INSTALL_OTHER_DEVICE.md)

## Always-on

| Файл | Назначение |
|---|---|
| `00-esti-core.mdc` | Продукт, политика, MCP, triage, индекс |
| `00-esti-device-profile.mdc` | POWER / LITE профиль |
| `32-agent-caveman-esti.mdc` | Стиль dev-задач (caveman) |
| `33-agent-error-learning-pipeline.mdc` | Ошибка → memory L0–L3 |
| `isolation_rules/Core/memory-bank-paths.mdc` | Пути Memory Bank |
| `orchestrator-bridge.mdc` + `AI-agent.mdc` | Python orchestrator |
| `global-caveman.mdc` | Ссылка на skill (on-demand) |

Коммуникация: `USER-RULES.md` в корне проекта.

## On-demand (сценарий → файл)

| Сценарий | Файл |
|---|---|
| Locate MCP | `03-mcp-locate.mdc` |
| Atlas POWER | `25-agent-bsl-atlas-esti.mdc` |
| Litecode | `27-agent-litecode-esti.mdc` |
| lean-ctx | `26-agent-lean-ctx-esti.mdc` |
| Verify перед сдачей | `34-agent-verification-checklist.mdc` |
| Системный дебаг | `35-agent-systematic-debugging.mdc` |
| Модуль формы | `36-agent-form-reserved-names.mdc` |
| Metadata XML | `37-agent-metadata-xml-workarounds.mdc` |
| Асинх на клиенте | `38-agent-async-methods.mdc` |
| Блокировки | `39-agent-locks-and-transactions.mdc` |
| Ловушки платформы | `40-agent-platform-solutions.mdc` |
| MCP playbooks | `41-agent-tooling-playbooks-esti.mdc` |
| CFE change control | `global-07-agent-extension-change-control-deep.mdc` |
| Крупная задача | `global-09-sdd-workflow-for-large-1c-tasks.mdc` |
| Skill router | `global-01-skill-router-1c8.mdc` |

Полный список: `.cursor/rules/*.mdc`.

## MCP v4 (POWER / LITE)

| POWER | LITE |
|---|---|
| bsl-atlas-esti + litecode | litecode + code-index |
| Serena edit | Serena edit |
| naparnik + v8std verify | naparnik + v8std |

Документация: `MCP_ROUTER_ESTI.md`, `MCP_TOOLS_MATRIX.md`, `MCP_LITE_DEVICE.md`.

## Память (вместо OpenSpec)

| Слой | Путь |
|---|---|
| L0 Task | `memory-bank/` |
| L1 Episodic | lean-ctx `ctx_knowledge` |
| L2 Project | `.serena/memories/` |
| L3 Rules | `.cursor/rules/*.mdc` |

Маршрутизация: `memory.md`.

## Навыки (глобально `~/.cursor/skills/`)

| Навык | Назначение | Setup |
|---|---|---|
| `esti-project` | Контекст ЭСТИ (workspace) | — |
| `mermaid-diagrams` | Диаграммы | — |
| `transcribe` | Аудио/видео → текст (faster-whisper) | `setup-once.ps1` |
| `md-to-docx` | Markdown → Word | `ensure-deps.ps1` |
| `handoff` | Сжатие сессии | — |
| `powershell-windows` | Shell Windows | — |
| `caveman` + siblings | Стиль, коммиты, ревью | — |
| `img-grid-analysis` | Сетка на скриншоте | — |

Единая установка deps: `.cursor/scripts/Install-ESTI-SkillDeps.ps1` (идемпотентно).

## Команды Cursor

| Команда | Назначение |
|---|---|
| `/doctor` | MCP + skill deps |
| `/handoff` | handoffs/handoff-*.md |
| `/caveman` | lite/full/ultra/off |
| `capture-error` | recall по ошибке |
| `reflect-lesson` | reflection + store |

## Не используем

- OpenSpec (→ `memory-bank/` + `global-09`)
- graph-metadata vibecoding
- `1c-templates-mcp`
- `zup-hr-api-reference` (это ЗУП)
- `prompt-enhancer`, `mcp-1c-tools` (свой роутер v4)

## Синхронизация

Глобальные правила: `~/.cursor/rules/` → `sync-global-rules.ps1` → проект. См. `CURSOR_SYNC.md`.

## Архив

Bulk `isolation_rules` (Level*, Phases, visual-maps): `.cursor/rules/_archive/isolation_rules/` — для Supercode custom modes.
