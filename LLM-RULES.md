# LLM-RULES.md — эволюционирующие правила (shared, все КФ)

Пишет **только** `/evolve` после явного approve пользователя по каждому пункту.  
Не редактировать вручную «за компанию» в обычном implement.  
SoT: `C:\1c-shared-patterns\cursor-addons\project-root\LLM-RULES.md` → Sync в проекты.

## Precedence

```text
USER explicit
  > memory.md / канон ИБ текущего проекта (infobasesettings / .dev.env)
  > LLM-RULES (этот файл)
  > AGENTS.md / on-demand .mdc / hub-gate
  > defaults
```

**Жёсткие исключения (LLM-RULES не может ослабить без USER):**
- MCP tool router / No WebFetch / no codegraph;
- safe-scope (не трогать типовую КФ без разрешения);
- CFE: `&Вместо` только с явным OK;
- Hub Gate: compact consult + `KB:` proof перед генерацией 1С-кода.

## Active

### 2026-07-20 — external-url-no-webfetch
- Scope: external URL / GitHub / GitLab
- Rule: URL репозитория → `/research-repo` (uploads → clone `%TEMP%` | `gh api` tree → `ctx_read`). Один публичный URL → `ctx_url_read`. `WebFetch` default **0**; >1 `WebFetch` на host за ход = `rule-friction` → снова `/evolve`.
- Why / Source: CREATIVE comol overfetch; `reflection-2026-07-20-comol-cherry-pick-no-webfetch.md`; approve = IMPLEMENT all phases W1–W5 (2026-07-20)

### 2026-07-23 — hub-gate-fplus-lite
- Scope: генерация/правка BSL, CFE/EPF/ERF, форм, Excel, query во всех КФ
- Rule: до кода — `C:\1c-shared-patterns\playbooks\agent-lessons\index.md` (max 2 файла); CFE/EPF — skill `reuse-1c-shared-patterns`. В ответе `KB: …` | `KB: none` | `KB: skip-cosmetic`. Переносимые уроки → Hub `agent-lessons` + Sync, не только project reflection. Shared `.mdc` править в Hub `rules-shared`, не в копии проекта.
- Why / Source: F+ Lite BUILD; approve A2/collapse/Serena (2026-07-23)

## Superseded

<!-- Перенесённые/отменённые Active-записи -->
