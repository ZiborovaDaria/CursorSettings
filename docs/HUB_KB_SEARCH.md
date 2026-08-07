# Hub KB Search — инструкция для агента

SoT playbook. Rule: `hub-gate.mdc`. Skills: `consult-1c-shared-lessons`, `reuse-1c-shared-patterns`.

## Когда искать в Hub

| Ситуация | Hub? | Куда |
|---|---|---|
| Разработка (код, CFE, metadata, rules, scripts, deploy, tests) | **Да** | lessons + patterns |
| Вопрос «как работает X в 1С» **без правок** | **Нет** | syntax-helper / naparnik / v8std |
| Косметика (rename, комментарий) | Skip | `KB: skip-cosmetic` |

## Алгоритм (до генерации кода)

```text
1. Lessons (anti-gotcha)
   a) Прочитать index.md — keyword match по surfaces/trigger?
   b) Если нет явного hit → dense:
      ctx_shell: python C:\1c-shared-patterns\scripts\Search-HubLessonsDense.py "<задача>" --top 3
   c) Fallback (Ollama down): Build-AgentLessonsCatalog.py --search "<задача>"
   d) Открыть max 1 lesson-файл → применить Required behavior

2. Patterns (how) — только при implement
   a) ctx_shell: python C:\1c-shared-patterns\scripts\Search-ContentPatternsDense.py "<задача>" --top 3
   b) Fallback: catalog\content_patterns_index.json (keyword)
   c) Открыть 1 pattern.md + при необходимости example_from_catalog.bsl
   d) Не изобретать — reuse эталон

3. Суммарно max 2 файла Hub (lesson + pattern)

4. Proof в ответе:
   KB: <id> | KB: none | KB: skip-cosmetic
   REUSE: <id> | REUSE: none (искал: dense + …)
```

## Пороги dense

| Score | Действие |
|---|---|
| ≥ 0.55 | считать hit, открыть файл |
| 0.40–0.55 | открыть только если keyword в index тоже близок |
| < 0.40 | не считать hit → `KB: none` / `REUSE: none` |

## Команды (полные пути)

```powershell
# Lessons
python C:\1c-shared-patterns\scripts\Search-HubLessonsDense.py "запрос в цикле" --top 3
python C:\1c-shared-patterns\scripts\Build-AgentLessonsCatalog.py --search "запрос в цикле"

# Patterns
python C:\1c-shared-patterns\scripts\Search-ContentPatternsDense.py "CFE после хук" --top 3

# Rebuild (после нового lesson/pattern)
python C:\1c-shared-patterns\scripts\Index-HubDenseAll.py
```

**Index not found** → `Index-HubDenseAll.py` (нужен Ollama `qwen3-embedding:4b` на `127.0.0.1:11434`).

## После ошибки (Store)

1. skill `error-learning-1c`
2. Portable → новый lesson + `index.md` + `Build-AgentLessonsCatalog.py` + `Index-HubLessonsDense.py`
3. Reply: `STORED: hub:<id>` или `PROMOTE_DEFER: <why>`

## Не делать

- Не читать весь Hub / все patterns
- Не писать код до `KB:` / `REUSE:` (кроме skip-cosmetic)
- Не дублировать HOW в lessons (patterns) и anti в patterns (lessons)
