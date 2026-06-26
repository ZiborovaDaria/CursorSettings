# Tech Context — ESTI

## Платформа и КФ
| Параметр | Значение |
|----------|----------|
| Платформа | 8.5.1.1150, Version8_5_1 |
| Конфигурация | `ЭСТИ_УправлениеФирмойФранчайзи_УправлениеНебольшойФирмой_CRM` 2.2.5.90 |
| Базовая КФ | УНФ 3.0.13.342 |
| Кодировка | utf-8 |
| Workspace | `C:\Cursor\ESTI` |
| device_profile | POWER (см. `00-esti-device-profile.mdc`) |

## Расширения
- Путь: `Extent/`
- Префикс: **ESTI** (`PREFIX` в `.dev.env`)

## MCP стек (v4)

### POWER (основной ПК)
| Сервер | Роль | Путь/порт |
|--------|------|-----------|
| bsl-atlas-esti | Locate BSL/метаданные | `http://localhost:8008/mcp`, индекс `C:\bsl-atlas-indexes\ESTI` |
| litecode | Семантика, права `get_access` | docker `C:\bsl-litecode-data\ESTI` |
| code-index | Fallback grep, repo **ESTI** | `C:\CursorMCP\` |
| serena | Edit BSL, memories | project MCP |
| lean-ctx | ctx_knowledge, ctx_read | global MCP |
| 1c-naparnik | check_1c_code, config_help(УНФ) | project MCP |
| v8std | Стандарты ITS | project MCP |

### LITE (слабый ПК)
- Только litecode + code-index (без Atlas)
- Merge: `mcp.profile.lite.json` → `.cursor/mcp.json`
- Подготовка: `Prepare-LitecodeData-ESTI.ps1`, `docker-compose.fast.yml`

## Правила и память
- Карта правил: `.cursor/RULES_INDEX.md`
- Error pipeline: `33-agent-error-learning-pipeline.mdc`
- Слои L0–L3: `memory.md`

## Скрипты
| Скрипт | Назначение |
|--------|------------|
| `Test-ESTI-MCPStack.ps1` | Проверка MCP |
| `Install-ESTI-SkillDeps.ps1` | deps transcribe + md-to-docx |
| `Get-BslAtlasIndexStatus-ESTI.ps1` | Статус индекса Atlas |

## .dev.env
`PLATFORM_PATH`, `INFOBASE_PATH`, `EXTENSION_NAME`, `SUBAGENT_MODEL_*` — см. `.dev.env`.
