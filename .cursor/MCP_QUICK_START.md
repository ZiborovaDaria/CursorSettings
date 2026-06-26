# MCP ЭСТИ — краткая инструкция подключения

Перезапуск Cursor после изменения `mcp.json`: **Settings → MCP → Reload**.

Профили: `mcp.profile.power.json` · `mcp.profile.lite.json` · см. `MCP_LITE_DEVICE.md`, [RULES_INDEX.md](RULES_INDEX.md) § синхронизация.

## Power profile (мощный ПК)

**Обязательны:** `bsl-atlas-esti` + `litecode` + `serena` + `code-index` + `mcp-1c` + `1c-naparnik` + `lean-ctx` (global).

| Сервис | Проверка | Если не работает |
|---|---|---|
| **1С + Apache** | `http://localhost/ESTI` | Запустить ИБ, опубликовать |
| **bsl-atlas-esti** | `docker ps --filter name=bsl-atlas-esti` | `cd C:\bsl-atlas-indexes\ESTI && docker compose up -d` |
| **litecode** | `docker ps --filter name=1c-metacode-esti` | `Prepare-LitecodeData-ESTI.ps1` → `infra/litecode-esti/docker compose up -d` |
| **Ollama** (Atlas embeddings) | `curl http://localhost:11434/api/tags` | `ollama pull qwen3-embedding:4b` |
| **1c-naparnik** | MCP :8007 зелёный | Запустить сервер Напарника |
| **code-index** | tool `health` | Reload MCP |

Статус: `powershell -File .cursor/scripts/Test-ESTI-MCPStack.ps1`

## Lite profile (слабый ПК)

**Без Atlas.** Только `litecode` + `code-index` + `serena` + `naparnik`.

1. `device_profile: LITE` в `00-esti-device-profile.mdc`
2. Merge `mcp.profile.lite.json` → `mcp.json`
3. Следовать `MCP_LITE_DEVICE.md`

## Как агент выбирает инструмент

```
POWER Locate → bsl-atlas-esti + litecode (get_access для ролей)
LITE Locate  → litecode
Fallback     → code-index (repo=ESTI)
Edit         → serena
Verify       → naparnik + v8std
ИБ           → mcp-1c / 1c-rest-mcp
Файлы        → lean-ctx
```

Подробно: `MCP_ROUTER_ESTI.md`, `MCP_TOOLS_MATRIX.md`, `03-mcp-locate.mdc`.

## bsl-atlas-esti: когда готов

| Состояние | Доступно |
|---|---|
| SQLite ready | `search_function`, `metadatasearch`, `read_function`, `code_grep` |
| ChromaDB 100% | + `codesearch`, `helpsearch` |

Пока Chroma < 100% — семантику: `metadatasearch` + `grep_body`.

## litecode: подготовка (Power и Lite)

```powershell
powershell -File .cursor/scripts/Prepare-LitecodeData-ESTI.ps1
cd .cursor/infra/litecode-esti
docker compose -f docker-compose.fast.yml up -d   # или docker-compose.yml (full)
```

Проверка: `{"op":"browse","category":"Documents"}` · `{"op":"get_access","target":"..."}`

`LOAD_ROLE_RIGHTS=true` — обязательно для прав ролей.

## Проверка после подключения

```powershell
powershell -File .cursor/scripts/Test-ESTI-MCPStack.ps1
powershell -File .cursor/scripts/Get-BslAtlasIndexStatus-ESTI.ps1
python C:\AI_AGENT\scripts\test_esti_mcp.py
```

## Безопасность mcp-1c

Пароль не в Git. Локально: `.cursor/mcp.local.json` (см. `mcp.local.json.example`).

## Частые проблемы

| Симптом | Решение |
|---|---|
| Atlas MCP offline | `docker compose up -d` в `C:\bsl-atlas-indexes\ESTI` |
| litecode `[]` | Нет mount данных → `Prepare-LitecodeData-ESTI.ps1` |
| `get_access` пустой | `LOAD_ROLE_RIGHTS=true`, нужен `ОтчетПоКонфигурации.txt` |
| mcp-1c 404 | HTTP-сервис + расширение MCP_HTTPService |
| 1c-rest-mcp auth | `patch-1c-rest-mcp-noauth.ps1` |
| Serena без locate | Сначала Atlas/litecode, потом Serena |

## Ссылки

| Сервер | Docs |
|---|---|
| bsl-atlas | https://github.com/Arman-Kudaibergenov/bsl-atlas |
| litecode | https://github.com/svhov/1c-metacode-lite-mcp |
| code-index | https://github.com/Regsorm/code-index-mcp |
| Матрица tools | `.cursor/MCP_TOOLS_MATRIX.md` |
