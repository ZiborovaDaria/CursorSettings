# System Patterns — ESTI

## Архитектура доработок
- Типовая КФ — только чтение; изменения в **CFE** (`Extent/`)
- Новые объекты — префикс **ESTI**
- Аннотации расширения: `&Перед`, `&После`, `&ИзменениеИКонтроль`
- **Запрещено:** `&Вместо`, `ПродолжитьВызов()`

## Locate → Edit → Verify
1. **Locate:** bsl-atlas-esti → litecode → code-index
2. **Understand:** lean-ctx `ctx_callgraph` / `ctx_impact`
3. **Edit:** Serena `replace_symbol_body` / `replace_content`
4. **Verify:** `check_1c_code`, v8std, ручной сценарий в ИБ

## BSL
- Клиент/сервер: данные на сервере, UI на клиенте
- Запросы: без запросов в цикле; параметры `&Имя`
- Минимальный дифф; не выдумывать имена метаданных

## Конвейер ошибок
См. `.cursor/rules/33-agent-error-learning-pipeline.mdc` и корневой `memory.md`.

## Правила Cursor (опорные)
- `00-esti-core.mdc`, `03-mcp-locate.mdc`
- `25-agent-bsl-atlas-esti.mdc`, `27-agent-litecode-esti.mdc`
- `global-07-agent-extension-change-control-deep.mdc`

## Serena memories
Точка входа: `mem:core` в `.serena/memories/core.md`
