# Tasks — ESTI

## Текущая задача
**Конвейер error → memory** — инициализация и проверка.

### Чеклист
- [x] Создать `memory-bank/` scaffold
- [x] Serena `core.md`, `pitfalls/cfe_bsl.md`, `memory_maintenance.md`
- [x] Правило `33-agent-error-learning-pipeline.mdc`
- [x] Обновить MCP_ROUTER (секция Memory)
- [x] Smoke-test: recall → fix → remember → reflection

### Результат smoke-test (2026-06-25)
- `ctx_knowledge remember` key `cfe-no-vmesto` — OK
- `ctx_knowledge recall` query «Вместо CFE» — hit
- Reflection: `memory-bank/reflection/reflection-2026-06-25-smoke-test-pipeline.md`

### Компоненты
| Шаг | Инструмент |
|-----|------------|
| Detect | `check_1c_code`, v8std |
| Recall | `ctx_knowledge recall`, `read_memory pitfalls/cfe_bsl` |
| Fix | Serena + MCP_ROUTER цепочка |
| Store | `ctx_knowledge remember`, `write_memory`, `reflection/*.md` |
| Promote | `.mdc` при ≥2 повторах |

---
*После завершения задачи: reflection → archive, очистить этот файл для следующей задачи.*
