# ЭСТИ на слабом ПК — Litecode primary

Инструкция для второго устройства без Atlas/Ollama. Пути те же: `C:\Cursor\ESTI`, `C:\bsl-litecode-data\ESTI`.

## 1. Требования

| Режим | RAM | Docker |
|---|---|---|
| **fast** (рекомендуется) | ~8 ГБ | Desktop |
| **full** (embedding) | ~16 ГБ | Desktop |

+ Git, Cursor, clone в `C:\Cursor\ESTI`.

## 2. Клонировать репозиторий

```powershell
git clone <repo-url> C:\Cursor\ESTI
cd C:\Cursor\ESTI
```

## 3. Профиль MCP

1. В `00-esti-device-profile.mdc` установить `device_profile: LITE`.
2. Merge `mcp.profile.lite.json` в `.cursor/mcp.json` (без `bsl-atlas-esti`, без `puppeteer`).
3. Cursor → Settings → MCP → **Reload**.

## 4. Подготовить данные litecode

```powershell
powershell -File .cursor/scripts/Prepare-LitecodeData-ESTI.ps1 -TargetPath C:\bsl-litecode-data\ESTI
```

## 5. Отчёт по конфигурации (обязательно)

Конфигуратор 1С → **Отчёт по конфигурации** → сохранить:

```
C:\bsl-litecode-data\ESTI\metadata\ОтчетПоКонфигурации.txt
```

## 6. Запуск fast (сначала)

```powershell
cd C:\Cursor\ESTI\.cursor\infra\litecode-esti
docker compose -f docker-compose.fast.yml up -d
docker logs -f 1c-metacode-esti
```

Дождаться окончания индексации в логах.

## 7. Проверка MCP

В Cursor вызвать `litecode` → `search_metadata`:

```json
{"op":"browse","category":"Documents"}
```

Права ролей:

```json
{"op":"get_access","target":"ЗаказПокупателя"}
```

Скрипт: `powershell -File .cursor/scripts/Test-ESTI-MCPStack.ps1`

## 8. Переключение на full (если хватает RAM)

```powershell
docker compose -f docker-compose.yml up -d
```

`ENABLE_EMBEDDING=true` — семантика через `search_by_embedding`.

## 9. Роутинг агента

- Правило: `27-agent-litecode-esti.mdc` (primary locate).
- Права: `28-agent-role-rights-esti.mdc`.
- Общий роутер: `03-mcp-locate.mdc` (секция LITE).

## 10. После git pull

При изменении `Roles/` или выгрузки КФ:

```powershell
# один раз
$env:FULL_METADATA_RELOAD='true'
docker compose -f docker-compose.fast.yml up -d --force-recreate 1c-metacode-esti
```

## 11. Locate → Edit

| Задача | Цепочка |
|---|---|
| Процедура | `get_routines` → `get_routine_body` → Serena |
| Семантика | `search_by_embedding` или `find_routines_by_description` |
| Права | `get_access` |
| Fallback | `code-index.grep_body` (repo: ESTI) |

## 12. Что НЕ запускать

- `bsl-atlas-esti`, Ollama
- `codegraph` (бесполезен для BSL)
- `puppeteer` (по умолчанию)

## Ссылки

- `MCP_QUICK_START.md` — секция Lite profile
- `CURSOR_SYNC.md` — синхронизация между ПК
- [litecode GitHub](https://github.com/svhov/1c-metacode-lite-mcp)
