# Установка ЭСТИ на новом устройстве — инструкция для агента и человека

Полный чеклист переноса **настроек Cursor-агента**, правил, навыков и MCP после `git clone`.

См. также: [RULES_INDEX.md](RULES_INDEX.md), [CURSOR_SYNC.md](CURSOR_SYNC.md).

---

## 0. Что в репозитории (Git)

| Путь | Содержимое |
|---|---|
| `.cursor/rules/` | Правила проекта (always-on + on-demand) |
| `.cursor/commands/` | Slash-команды (`/doctor`, `/handoff`, `/caveman`, …) |
| `.cursor/scripts/` | Установка, MCP, архив |
| `.cursor/export/global-rules/` | Все `~/.cursor/rules/*.mdc` (24) |
| `.cursor/export/global-skills/` | **Все** глобальные навыки (~99): 1c-*, caveman*, mermaid, transcribe, … |
| `.cursor/export/global-scripts/` | `sync-global-rules.ps1`, `sync-project-mcp.ps1` |
| `.cursor/export/global-templates/` | `mcp.project.template.json` |
| `.cursor/export/supercode/` | Режимы Memory Bank для [supercode.sh](https://supercode.sh) |
| `.cursor/mcp.profile.power.json` | Шаблон MCP (мощный ПК) |
| `.cursor/mcp.profile.lite.json` | Шаблон MCP (слабый ПК) |
| `.cursor/skills/esti-project/` | Контекст конфигурации ЭСТИ |
| `USER-RULES.md` | Стиль ответа (caveman vs prose) |
| `memory.md`, `memory-bank/` | Memory Bank L0 |
| `.dev.env.example` | Шаблон переменных проекта |

**Не в Git** (создать локально):

| Файл | Назначение |
|---|---|
| `.cursor/mcp.json` | Активный MCP (из profile) |
| `.cursor/mcp.local.json` | Секреты (пароль mcp-1c) |
| `.dev.env` | Пути ИБ, пароли, разработчик |
| `infobasesettings.md` | Подключение к ИБ |

---

## 1. Предварительные требования

### Общие

- Windows 10/11
- [Cursor](https://cursor.com/) установлен
- [Git](https://git-scm.com/)
- Пути как на основном ПК (рекомендуется):
  - `C:\Cursor\ESTI` — workspace
  - `C:\CursorMCP\` — бинарники MCP
  - `C:\bsl-litecode-data\ESTI` — данные litecode

### Мощный ПК (POWER)

- Docker Desktop
- Atlas index: `C:\bsl-atlas-indexes\ESTI`
- RAM 16+ ГБ

### Слабый ПК (LITE)

- Docker Desktop (fast compose)
- RAM 8+ ГБ
- Без Atlas — см. [MCP_LITE_DEVICE.md](MCP_LITE_DEVICE.md)

### Опционально для навыков

- Python 3.9+ + `pip` (навык `transcribe`)
- ffmpeg: `winget install ffmpeg`
- Node.js (навык `md-to-docx`)

---

## 2. Клонирование

```powershell
git clone <URL-репозитория> C:\Cursor\ESTI
cd C:\Cursor\ESTI
```

Открыть папку в Cursor: **File → Open Folder → `C:\Cursor\ESTI`**.

---

## 3. Автоустановка настроек (рекомендуется)

### Мощный ПК

```powershell
powershell -ExecutionPolicy Bypass -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

### Слабый ПК

```powershell
powershell -ExecutionPolicy Bypass -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile LITE
```

Скрипт:
1. Копирует `export/global-rules` → `%USERPROFILE%\.cursor\rules\`
2. Копирует `export/global-skills` → `%USERPROFILE%\.cursor\skills\`
3. Создаёт `.cursor/mcp.json` из profile
4. Запускает `Install-ESTI-SkillDeps.ps1` (transcribe, md-to-docx)
5. Вызывает `sync-global-rules.ps1` → `global-*.mdc` в проекте

---

## 4. Ручные шаги после скрипта

### 4.1 Cursor User Rules (обязательно для caveman)

**Cursor → Settings → Rules → User Rules** — добавить:

> В workspace ESTI при задачах кодинга/дебага 1С — краткий caveman-стиль по `USER-RULES.md` проекта, не развёрнутый blog-post prose.

### 4.2 `.dev.env`

```powershell
Copy-Item .dev.env.example .dev.env
# Отредактировать INFOBASE_PATH, DEVELOPER, IB_PASSWORD, PLATFORM_PATH
```

### 4.3 `infobasesettings.md`

Создать в корне репо (не коммитить) по образцу с основного ПК.

### 4.6 Supercode (Memory Bank modes)

```powershell
# Уже скопировано Install-ESTI-OnNewDevice.ps1 в .supercode/
```

Cursor → Extensions → установить **supercode.supercode-sh** (см. `.vscode/extensions.json`).

Режимы: VAN, PLAN, CREATIVE, IMPLEMENT, REFLECT, ARCHIVE — в `.supercode/modes/memory-bank/`.

### 4.7 MCP Reload

Cursor → **Settings → MCP → Reload**.

### 4.5 Профиль устройства

В `.cursor/rules/00-esti-device-profile.mdc` проверить:

```
device_profile: POWER   # или LITE
```

На LITE — не коммитить `LITE` в main, держать локально (см. CURSOR_SYNC.md).

---

## 5. MCP-стек по профилю

### POWER

```powershell
# Litecode
cd .cursor\infra\litecode-esti
docker compose up -d

# Atlas — статус индекса
powershell -File .cursor\scripts\Get-BslAtlasIndexStatus-ESTI.ps1

# Полная проверка
powershell -File .cursor\scripts\Test-ESTI-MCPStack.ps1
```

Документация: [MCP_QUICK_START.md](MCP_QUICK_START.md), [MCP_SETUP_ESTI.md](MCP_SETUP_ESTI.md).

### LITE

```powershell
powershell -File .cursor\scripts\Prepare-LitecodeData-ESTI.ps1
cd .cursor\infra\litecode-esti
docker compose -f docker-compose.fast.yml up -d
```

Документация: [MCP_LITE_DEVICE.md](MCP_LITE_DEVICE.md).

---

## 6. Проверка агента

В чате Cursor:

| Команда | Ожидание |
|---|---|
| `/doctor` | Отчёт по MCP + skill deps |
| «Исправь опечатку в модуле формы» | 2–4 коротких предложения (caveman) |
| Задача на ревью | Связный русский, не caveman |

---

## 7. Инструкция для агента (краткая)

При старте сессии в workspace `C:\Cursor\ESTI`:

1. **Always-on:** `00-esti-core.mdc`, `00-esti-device-profile.mdc`, `32-agent-caveman-esti.mdc`, `33-agent-error-learning-pipeline.mdc`
2. **Стиль:** dev → caveman (`USER-RULES.md`); review/docs → prose
3. **Locate:** `03-mcp-locate.mdc` — Atlas (POWER) или litecode (LITE)
4. **Verify:** naparnik + v8std; gate `34-agent-verification-checklist.mdc`
5. **Память:** recall перед fix → store после (`33-agent-error-learning-pipeline.mdc`)
6. **Индекс:** [RULES_INDEX.md](RULES_INDEX.md)

On-demand по сценарию — таблица в `00-esti-core.mdc` § «Индекс on-demand правил».

---

## 8. Обновление с основного ПК

После изменений правил на основном ПК:

```powershell
# 1. Обновить bundle в репо (на основном ПК)
Copy-Item "$env:USERPROFILE\.cursor\rules\*.mdc" .cursor\export\global-rules\ -Force
# ... skills аналогично (или перезапустить Install на источнике)

# 2. Коммит и push
git add .cursor USER-RULES.md memory.md memory-bank .dev.env.example .gitignore
git commit -m "chore(cursor): sync agent settings"
git push

# 3. На втором ПК
git pull
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
# Cursor → MCP Reload
```

Глобальный sync в другие проекты 1С:

```powershell
powershell -File $env:USERPROFILE\.cursor\scripts\sync-global-rules.ps1
```

---

## 9. Структура always-on vs on-demand

### Always-on

- `00-esti-core.mdc` — продукт, MCP, triage, индекс
- `00-esti-device-profile.mdc` — POWER/LITE
- `32-agent-caveman-esti.mdc` — стиль dev-задач
- `33-agent-error-learning-pipeline.mdc` — ошибка → memory
- `isolation_rules/Core/memory-bank-paths.mdc` — пути Memory Bank

### On-demand (примеры)

| Сценарий | Файл |
|---|---|
| Verify | `34-agent-verification-checklist.mdc` |
| Debug | `35-agent-systematic-debugging.mdc` |
| Form module | `36-agent-form-reserved-names.mdc` |
| XML metadata | `37-agent-metadata-xml-workarounds.mdc` |
| MCP chains | `41-agent-tooling-playbooks-esti.mdc` |

Полный список: [RULES_INDEX.md](RULES_INDEX.md).

---

## 10. Troubleshooting

| Проблема | Решение |
|---|---|
| Caveman не работает | User Rules исключение + `32-agent-caveman-esti.mdc` |
| MCP не отвечает | `/doctor`, Reload MCP, docker ps |
| Atlas не найден | POWER only; на LITE — litecode |
| transcribe падает | `winget install ffmpeg`, `setup-once.ps1` |
| md-to-docx падает | `ensure-deps.ps1`, Node.js |
| global-* устарели | `Install-ESTI-OnNewDevice.ps1` или `sync-global-rules.ps1` |

---

## 11. Что не переносится

- OpenSpec (заменён `memory-bank/`)
- `zup-hr-api-reference` (только ЗУП)
- Docker volumes / индексы Atlas (пересоздать на ПК)
- `prompt-enhancer`, `mcp-1c-tools` из ai_rules_1c
