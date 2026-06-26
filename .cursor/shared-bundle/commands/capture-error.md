# Capture Error — ESTI

Быстрая фиксация ошибки и запуск recall перед исправлением.

## Вход

Пользователь указывает текст ошибки, объект, модуль или вставляет вывод `check_1c_code` / runtime.

## Действия

1. **Recall**
   - `ctx_knowledge(action=recall, query=<текст ошибки>)`
   - Serena `read_memory` → `pitfalls/cfe_bsl`
   - bsl-atlas-esti `codesearch` / `search_function` при поиске типового аналога
2. Кратко сообщить: найденные уроки / аналоги или «в памяти нет».
3. После исправления (по запросу или автоматически) — **Store** по `33-agent-error-learning-pipeline.mdc`:
   - `ctx_knowledge remember`
   - при необходимости reflection-файл в `memory-bank/reflection/`

Не исправлять код без явного запроса, если пользователь только передал текст ошибки для фиксации.
