# Migration Report — final v3

## 1. Что исправлено после критики v2

В v2 была правильная архитектура, но были потери боевого функционала. В v3 это исправлено.

| Проблема v2 | Что сделано в v3 |
|---|---|
| Нет старых эксплуатационных команд | Возвращены `getconfigfiles`, `deploy_and_test`, `capture-error`, `reflect-lesson`, `handoff`, `check-uuid`, `caveman` |
| `/build` конфликтует со старым `IMPLEMENT` | Добавлен `/implement` как основной совместимый режим; `/build` оставлен как алиас |
| Skill-router ссылался на несуществующие skills | Добавлены реальные `SKILL.md`: CFE, EPF, ERF, metadata, forms, queries, MCP, handoff, testing, error-learning, orchestrator |
| Слишком общий MCP-first | Добавлен `project-esti-mcp-router-agent.mdc` с POWER/LITE-матрицей |
| Потерян orchestrator JSON contract | Добавлен `project-esti-orchestrator-bridge-agent.mdc` + skill `orchestrator-bridge` |
| Потерян single 1C launch | Добавлен `project-esti-single-1c-launch-agent.mdc` |
| Проверки были общими | Добавлены `1c-testing-release-agent.mdc` и `1c-yaxunit-agent.mdc` |
| Error-learning был упрощен | Добавлен `project-esti-error-learning-agent.mdc` и команда `capture-error` |
| OpenSpec конфликтовал со старой политикой | `open-spec-sdd-agent.mdc` переведен в optional-only, Memory Bank остается дефолтом |
| `&Вместо` стало спорным | В v3 сделан BLOCKER: только после явного утверждения |

## 2. Что оставлено из v2

Оставлена сильная часть v2:

- короткие always-on диспетчеры;
- `1c-code-writing-agent.mdc` для прямого написания кода;
- разделение global / auto-by-glob / agent-requested;
- Memory Bank как центральный workflow;
- `.dev.env` как источник операционных параметров;
- переносимость между 1С-проектами.

## 3. Что восстановлено из старых правил CursorSettings

Восстановлены идеи из старых правил без копирования хаоса и дублей:

- ESTI context: конфигурация, workspace, CFE policy, опорные объекты;
- MCP v4: POWER/LITE, Atlas/litecode/code-index/Serena/naparnik/v8std;
- Caveman routing;
- Error → memory → rule promotion;
- Запрет на выдумывание метаданных;
- Single instance 1C launch;
- Orchestrator JSON mode;
- Команды для выгрузки, проверки, ошибок и handoff.

## 4. Что взято из comol/ai_rules_1c

Использованы идеи, которые не противоречат твоему проекту:

- always-on правила должны быть короткими;
- on-demand правила подключаются по задаче;
- skills должны существовать физически, а не быть только ссылками в router;
- `.dev.env` хранит параметры проекта;
- MCP-first поиск перед grep;
- отдельные playbooks для CFE/EPF/metadata/forms/queries;
- установка должна быть overlay-friendly и не обязана перезаписывать пользовательские файлы без backup.

## 5. Что принципиально не внедрено

- OpenSpec не стал дефолтным процессом, потому что в твоей старой системе явно используется Memory Bank/Supercode workflow.
- `&Вместо` не разрешен свободно: только через blocker и явное утверждение.
- Реальные секреты, логины, пароли и локальные пути не записаны в правила; для этого `.dev.env`.
- Старые правила не копировались целиком; они сведены в более короткие project-specific правила.

## 6. Финальная рекомендация

v3 можно ставить как новый основной overlay. Старые правила лучше не смешивать с ним напрямую. Если оставить старые `.mdc` активными, Cursor может получить две конкурирующие инструкции.

Правильная схема:

```text
1. backup .cursor
2. распаковать v3
3. старые правила → _legacy/*.mdc.off
4. проверить /doctor
5. проверить 3–5 реальных задач
6. точечно вернуть только недостающие старые сценарии
```
