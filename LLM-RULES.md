# LLM-RULES.md — эволюционирующие правила проекта BP

Пишет **только** `/evolve` после явного approve пользователя по каждому пункту.  
Не редактировать вручную «за компанию» в обычном implement.

## Precedence

```text
USER explicit
> memory.md / канон ИБ (BP_199_13, версия КФ)
> LLM-RULES (этот файл)
> AGENTS.md / on-demand .mdc
> defaults
```

**Жёсткие исключения (LLM-RULES не может ослабить без USER):**
- `24-always-mcp-tool-router` / No WebFetch / no codegraph;
- safe-scope (не трогать типовую КФ без разрешения);
- CFE: `&Вместо` только с явным OK.

## Active

### 2026-07-20 — external-url-no-webfetch
- Scope: external URL / GitHub / GitLab
- Rule: URL репозитория → `/research-repo` (uploads → clone `%TEMP%` | `gh api` tree → `ctx_read`). Один публичный URL → `ctx_url_read`. `WebFetch` default **0**; >1 `WebFetch` на host за ход = `rule-friction` → снова `/evolve`.
- Why / Source: CREATIVE comol overfetch; `reflection-2026-07-20-comol-cherry-pick-no-webfetch.md`; approve = IMPLEMENT all phases W1–W5 (2026-07-20)

## Superseded

<!-- Перенесённые/отменённые Active-записи -->
