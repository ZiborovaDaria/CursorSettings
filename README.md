# Cursor Memory Bank 1C Rules — final v3

Финальный overlay-набор правил для 1С-проектов в Cursor: **Memory Bank + обычный Agent Mode + боевые ESTI workflow**.

## Цель

Этот архив не просто заменяет старые правила более короткими. Он объединяет:

- современную структуру Cursor Project Rules (`.cursor/rules/*.mdc`);
- Memory Bank workflow `/van → /plan → /creative → /implement|/build → /reflect → /archive`;
- обычный Agent Mode без обязательного вызова slash-команд;
- ESTI-specific MCP-матрицу POWER/LITE;
- orchestrator JSON-режим для связки `LM Studio → orchestrator.py → Cursor Agent CLI`;
- запуск/проверку 1С без параллельного конфликта DESIGNER/ENTERPRISE;
- YAxUnit / naparnik / v8std / syntax-check слой;
- error-learning pipeline: `ошибка → recall → fix → store → promote`;
- skills, которые реально существуют и соответствуют skill-router.

## Быстрая установка

1. Сделайте backup текущих правил:

```powershell
cd C:\Cursor\ESTI
Copy-Item .cursor .cursor.backup-$(Get-Date -Format yyyyMMdd-HHmmss) -Recurse -ErrorAction SilentlyContinue
Copy-Item AGENTS.md AGENTS.backup.md -ErrorAction SilentlyContinue
Copy-Item memory.md memory.backup.md -ErrorAction SilentlyContinue
```

2. Распакуйте архив в корень проекта с заменой файлов.

3. Создайте локальный `.dev.env` из шаблона:

```powershell
Copy-Item .dev.env.example .dev.env -ErrorAction SilentlyContinue
notepad .dev.env
```

4. Перезапустите Cursor: `Developer: Reload Window`.

5. Выполните проверку:

```text
/doctor
```

## Основная структура

```text
.
├── AGENTS.md
├── USER-RULES.md
├── memory.md
├── .cursorrules
├── .dev.env.example
├── .cursor/
│   ├── RULES_INDEX.md
│   ├── commands/
│   │   ├── van.md
│   │   ├── plan.md
│   │   ├── creative.md
│   │   ├── implement.md
│   │   ├── build.md
│   │   ├── reflect.md
│   │   ├── archive.md
│   │   ├── doctor.md
│   │   ├── checkmcp.md
│   │   ├── evolve.md
│   │   ├── research-repo.md
│   │   ├── getconfigfiles.md
│   │   ├── deploy_and_test.md
│   │   ├── capture-error.md
│   │   ├── reflect-lesson.md
│   │   ├── handoff.md
│   │   ├── check-uuid.md
│   │   └── caveman.md
│   ├── rules/
│   └── skills/
├── memory-bank/
├── tools/
└── docs/
```

## Важная идея v3

Always-on правил мало и они короткие. Они не пытаются вместить весь справочник 1С. Их задача — включить правильный маршрут:

```text
обычный Agent Mode или slash command
  → AGENTS.md
  → short always-on routers
  → memory-bank context
  → project/1C rule
  → конкретный skill
  → код/проверка/отчет
```

## Что нельзя делать после установки

- Не удаляйте сразу старый `.cursor.backup-*`.
- Не смешивайте новые правила с активными дублями в `.cursor/rules/_archive/` или `.cursor/rules/_legacy/`, если эти файлы всё ещё имеют расширение `.mdc`.
- Если хотите оставить старое правило как справку, переименуйте его в `.mdc.off`.
- Не храните секреты в `.dev.env.example`; реальные логины/пароли только в локальном `.dev.env`.

## Минимальная проверка после установки

Попросите Cursor выполнить 4 тестовых сценария:

1. `/van` — должен создать/обновить задачу в `memory-bank/tasks.md`.
2. `/implement` или `/build` — должен писать код при задаче на реализацию.
3. `capture-error` — должен включить error-learning pipeline.
4. `deploy_and_test` — должен проверить single-1C-launch правило и `.dev.env`.

## Что делать со старыми правилами

Рекомендация: не удалять, а временно вынести:

```text
.cursor/rules/_legacy/*.mdc.off
```

Из старых правил v3 уже вобрал главное: ESTI core, MCP POWER/LITE, orchestrator JSON, single 1C launch, error-learning, tooling playbooks, YAxUnit/testing и эксплуатационные команды.

## Changelog 2026-07-20 — No WebFetch + comol cherry-pick

Источник опыта: проект BP ([архив в memory-bank](.)), идеи [comol/ai_rules_1c](https://github.com/comol/ai_rules_1c) — **cherry-pick**, не full install.

| Добавлено | Назначение |
|---|---|
| `/research-repo`, `/checkmcp`, `/evolve` | дешёвый GitHub research; MCP smoke; LLM-RULES с approve |
| `LLM-RULES.md` | эволюция правил |
| `26-always-no-webfetch.mdc` (stub) | якорь; канон в `24-always-mcp-tool-router` § No WebFetch |
| `24-always-mcp-tool-router.mdc` | MCP router + No WebFetch (Atlas/code-index/lean-ctx) |
| `lean-ctx.mdc` | WebFetch → `ctx_url_read` |
| `1c-logging/dcs/registers/verification-policy-agent.mdc` | on-demand |
| `MCP_PLAYBOOKS.md` | цепочки BSL/форма/CFE/URL |
| `scripts/mcp_usage_stats.py` | KPI + `webfetch_*` |

После установки: **Reload Window**, `/doctor`, `/checkmcp`. Не копировать чужой `mcp-servers.json` поверх боевого `mcp.json`.
