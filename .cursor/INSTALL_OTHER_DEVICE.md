# Установка ЭСТИ на новом устройстве

Полный чеклист: Cursor, MCP, память агента, litecode/Atlas. См. [RULES_INDEX.md](RULES_INDEX.md) · [INSTALL_ALL_PROJECTS.md](INSTALL_ALL_PROJECTS.md).

**Пути (одинаковые на всех ПК):**

| Что | Путь |
|---|---|
| Workspace / выгрузка КФ | `C:\Cursor\ESTI` |
| Файловая ИБ | см. `infobasesettings.md` |
| HTTP | `http://localhost/ESTI` |
| MCP binaries | `C:\CursorMCP\` |
| Atlas index | `C:\bsl-atlas-indexes\ESTI` |
| Litecode data | `C:\bsl-litecode-data\ESTI` |

---

## 1. Глобально (один раз на ПК)

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1   # если нет .cursor/export
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Скрипт ставит:
- `~/.cursor/rules` (24), `~/.cursor/skills` (99)
- `~/.cursor/scripts` (`sync-global-rules.ps1`, `sync-project-mcp.ps1`)
- `~/.cursor/templates`
- `.supercode/` (режимы Memory Bank)
- `.cursor/mcp.json` ← `mcp.profile.power.json` (или `-Profile LITE`)
- deps навыков: transcribe, md-to-docx (`Install-ESTI-SkillDeps.ps1`)

---

## 2. Настройки workspace ЭСТИ

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

Создаёт/обновляет (если ещё нет):
- `memory-bank/` — скелет Memory Bank (L0)
- `memory.md` — карта слоёв памяти L0–L3
- `handoffs/` — для `/handoff`
- `.supercode/` — режимы van/plan/implement/…
- `.vscode/extensions.json` — рекомендация `supercode.supercode-sh`
- синхронизацию `global-*.mdc` в `.cursor/rules/`

**Memory Bank (L0)** — файлы в `memory-bank/`:

| Файл | Назначение |
|---|---|
| `projectbrief.md` | Продукт, цели, опорные объекты |
| `productContext.md` | Контекст продукта |
| `techContext.md` | Платформа, MCP, скрипты |
| `systemPatterns.md` | Паттерны решений |
| `activeContext.md` | Текущий фокус |
| `progress.md` | Прогресс задач |
| `tasks.md` | Активная задача (ephemeral) |
| `reflection/` | Ретроспективы (`reflect-lesson`) |
| `archive/` | Архив завершённых задач |
| `creative/` | Creative phase |

В репозитории ESTI skeleton уже заполнен — на новом ПК после clone ничего дополнительно инициализировать не нужно, если папка есть.

---

## 3. Локальные файлы (вручную, не в git)

| Файл | Действие |
|---|---|
| **User Rules** | Текст из `USER-RULES.md` → Cursor Settings → Rules |
| **`.dev.env`** | Скопировать из [`.dev.env.example`](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.dev.env.example) — пути ИБ, платформа, `PREFIX=ESTI`, модели субагентов |
| **`infobasesettings.md`** | Создать локально: путь ИБ, HTTP, OData, `hs/mcp-1c` (шаблон — см. соседний файл в workspace) |
| **`mcp.local.json`** | Секреты mcp-1c / REST — из [example](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/mcp.local.json.example) |
| **`device_profile`** | В `00-esti-device-profile.mdc`: `POWER` (основной ПК) или `LITE` (слабый ПК) |

Расширение Cursor: **supercode.supercode-sh** (см. `.vscode/extensions.json`).

---

## 4. Информационная база и публикация

1. Файловая ИБ — путь из `infobasesettings.md` / `.dev.env` (`INFOBASE_PATH`).
2. Опубликовать на Apache: `http://localhost/ESTI`.
3. Проверка OData: `http://localhost/ESTI/odata/standard.odata/$metadata` (Basic Auth).
4. HTTP-сервис `hs/mcp-1c` — для `mcp-1c` (если 404 → метаданные через выгрузку / code-index).
5. Запуск 1С: `/N Admin /P <пароль>` — см. `21-agent-single-1c-launch.mdc`.

---

## 5. MCP — профиль POWER (по умолчанию)

После install: **Cursor → Settings → MCP → Reload**.

### 5.1 Обязательные серверы

| Сервер | Роль | Проверка |
|---|---|---|
| `bsl-atlas-esti` | Locate BSL/метаданные | `docker ps --filter name=bsl-atlas-esti` |
| `litecode` | Семантика, `get_access` (права) | `docker ps --filter name=1c-metacode-esti` |
| `code-index` | Fallback grep, repo **ESTI** | tool `health` |
| `serena` | Edit BSL | project MCP, зелёный |
| `1c-naparnik` | check_1c_code, УНФ help | `:8007` |
| `lean-ctx` | ctx_read, ctx_knowledge | global `~/.cursor/mcp.json` |
| `mcp-1c` / `1c-rest-mcp` | Живая ИБ | HTTP / OData |
| `v8std` | Стандарты 1С | https |

Подробно: [MCP_QUICK_START.md](MCP_QUICK_START.md) · [MCP_ROUTER_ESTI.md](MCP_ROUTER_ESTI.md) · [MCP_TOOLS_MATRIX.md](MCP_TOOLS_MATRIX.md).

**Не использовать для BSL:** `codegraph` (индексирует XML, не BSL). Папку `.codegraph/` можно удалить.

### 5.2 bsl-atlas-esti

```powershell
cd C:\bsl-atlas-indexes\ESTI
docker compose up -d
ollama pull qwen3-embedding:4b    # embeddings для Chroma
powershell -File C:\Cursor\ESTI\.cursor\scripts\Get-BslAtlasIndexStatus-ESTI.ps1
```

Исходники индекса: `C:\Cursor\ESTI`. Пока Chroma < 100% — семантика через `metadatasearch` + `grep_body`.

### 5.3 litecode (пересборка под проект ЭСТИ)

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Prepare-LitecodeData-ESTI.ps1 -TargetPath C:\bsl-litecode-data\ESTI
```

Скрипт создаёт:
- junction `C:\bsl-litecode-data\ESTI\code` → `C:\Cursor\ESTI`
- каталог `metadata/`

**Обязательно** — отчёт по конфигурации (для `get_access` и графа прав):

Конфигуратор 1С → **Отчёт по конфигурации** → сохранить:

```
C:\bsl-litecode-data\ESTI\metadata\ОтчетПоКонфигурации.txt
```

Запуск контейнера:

```powershell
cd C:\Cursor\ESTI\.cursor\infra\litecode-esti
docker compose -f docker-compose.fast.yml up -d    # ~8 ГБ RAM
# или docker compose up -d                         # full + embedding, ~16 ГБ
```

Проверка в MCP `litecode`:

```json
{"op":"browse","category":"Documents"}
{"op":"get_access","target":"ЗаказПокупателя"}
```

`LOAD_ROLE_RIGHTS=true` в compose — обязательно для прав ролей.

### 5.4 code-index (bsl-indexer)

Бинарник: `C:\CursorMCP\` · alias repo: **ESTI** = workspace.  
Не путать с `codegraph`. После первого открытия workspace — Reload MCP.

### 5.5 Живая ИБ (mcp-1c, REST)

- `mcp-1c.exe` → `http://localhost/ESTI/hs/mcp-1c`
- Пароль — только в `mcp.local.json`, не в git
- REST MCP: при ошибке auth → `powershell -File .cursor\scripts\patch-1c-rest-mcp-noauth.ps1`

### 5.6 Память агента (L1–L2)

| Слой | Где | Инициализация |
|---|---|---|
| L1 episodic | lean-ctx `ctx_knowledge` | автоматически при `capture-error` / `reflect-lesson` |
| L2 invariant | `.serena/memories/` | `read_memory` → `mem:core`, `pitfalls/cfe_bsl` |
| L3 rules | `.cursor/rules/*.mdc` | через Spread / install |

Корневая карта: `memory.md`. Конвейер ошибок: `33-agent-error-learning-pipeline.mdc`.

---

## 6. Навык проекта

Workspace-навык: `.cursor/skills/esti-project/SKILL.md` (контекст ЭСТИ УНФ).

---

## 7. Проверка

```powershell
powershell -File .cursor\scripts\Test-ESTI-MCPStack.ps1
powershell -File .cursor\scripts\Get-BslAtlasIndexStatus-ESTI.ps1
```

В Cursor: `/doctor` · тестовая dev-задача → caveman · review → связный русский.

---

## 8. Профиль LITE (слабый ПК)

1. `device_profile: LITE` в `00-esti-device-profile.mdc`
2. `Install-ESTI-OnNewDevice.ps1 -Profile LITE` или merge `mcp.profile.lite.json` → `mcp.json`
3. Без Atlas/Ollama — только litecode + code-index
4. Полная инструкция: [MCP_LITE_DEVICE.md](MCP_LITE_DEVICE.md)

---

## 9. Профили MCP (справочно)

| Файл | Назначение |
|---|---|
| `mcp.profile.power.json` | Шаблон POWER → `mcp.json` |
| `mcp.profile.lite.json` | Шаблон LITE |
| `mcp.local.json.example` | [GitHub](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/mcp.local.json.example) → `mcp.local.json` |

Активный `mcp.json` не в git — создаётся install-скриптом.

---

## 10. Обновление настроек

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1   # если export удалён локально
powershell -File .cursor\scripts\Export-CursorSettings.ps1
powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
git add -A; git commit -m "chore: sync cursor"; git push
powershell -File .cursor\scripts\Remove-LocalDistributionBundle.ps1        # опционально после push
```

На втором ПК: `git pull` → `Install-ESTI-OnNewDevice.ps1` → `Install-Project-OnNewDevice.ps1` → Reload MCP → при необходимости `Prepare-LitecodeData-ESTI.ps1` + docker.

---

## 11. Что не нужно в ежедневной работе

| Путь | Где хранится | Восстановление |
|---|---|---|
| `.cursor/export/` | GitHub | `Restore-DistributionBundleFromGit.ps1` |
| `.cursor/shared-bundle/` | GitHub | то же |
| `.dev.env.example`, `mcp.local.json.example` | GitHub | то же |
| `.codegraph/` | локальный мусор | удалить |

Рабочие: `.cursor/rules/`, `mcp.json`, `memory-bank/`, `mcp.profile.*.json`, `projects.manifest.json`.
