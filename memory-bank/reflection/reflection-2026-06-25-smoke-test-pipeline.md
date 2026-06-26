# Reflection: smoke-test error pipeline (2026-06-25)

## Ошибка / проблема
Синтетический сценарий: агент пытается использовать `&Вместо` в расширении CFE для ESTI.

## Причина
Нарушение политики расширений ЭСТИ — допустимы только `&Перед`, `&После`, `&ИзменениеИКонтроль`.

## Решение
Переписать перехват через `&ИзменениеИКонтроль` или `&После`; см. типовой паттерн в bsl-atlas-esti.

## Проверка конвейера
- [x] `ctx_knowledge remember` — key `cfe-no-vmesto`
- [x] `ctx_knowledge recall` по запросу «Вместо CFE» — hit
- [x] Serena `pitfalls/cfe_bsl.md` — seed
- [x] Правило `33-agent-error-learning-pipeline.mdc` — создано

## Повторяемость
Да — типичная ошибка LLM в CFE; уже в L2 (`pitfalls/cfe_bsl`) и L1 (lean-ctx).

## Файлы
- `.cursor/rules/33-agent-error-learning-pipeline.mdc`
- `.serena/memories/pitfalls/cfe_bsl.md`
