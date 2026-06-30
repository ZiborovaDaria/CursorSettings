# ESTI — Cursor Agent Settings

Репозиторий: **[github.com/ZiborovaDaria/CursorSettings](https://github.com/ZiborovaDaria/CursorSettings)**

Настройки Cursor-агента для проекта **ЭСТИ** (УНФ 2.2.5.90).

## Быстрый старт на новом ПК

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Полная инструкция: **[`.cursor/INSTALL_OTHER_DEVICE.md`](.cursor/INSTALL_OTHER_DEVICE.md)**  
Все проекты `C:\Cursor\`: **[`.cursor/INSTALL_ALL_PROJECTS.md`](.cursor/INSTALL_ALL_PROJECTS.md)**

## Документация

| Файл | Назначение |
|---|---|
| [RULES_INDEX.md](.cursor/RULES_INDEX.md) | Карта правил, MCP, синхронизация |
| [INSTALL_OTHER_DEVICE.md](.cursor/INSTALL_OTHER_DEVICE.md) | Установка ЭСТИ |
| [INSTALL_ALL_PROJECTS.md](.cursor/INSTALL_ALL_PROJECTS.md) | Все проекты C:\Cursor, litecode, memory-bank |
| [USER-RULES.md](USER-RULES.md) | Стиль caveman |

## Supercode Memory Bank

Расширение **supercode.supercode-sh**. Modes в `.supercode/modes/memory-bank/`:

| Mode | Файл | Назначение |
|---|---|---|
| VAN | `van.yml` | Инициализация, complexity |
| PLAN | `plan.yml` | Планирование |
| CREATIVE | `creative.yml` | Дизайн-решения |
| IMPLEMENT | `implement.yml` | Реализация |
| REFLECT | `reflect.yml` | Ретроспектива |
| ARCHIVE | `archive.yml` | Архивация задачи |

Документы задачи: `memory-bank/tasks.md` (source of truth), `progress.md`, `reflection/`, `archive/`.

Установка на все проекты: `.cursor/INSTALL_ALL_PROJECTS.md` §3.

## Примечание

Этот коммит содержит **настройки агента** (`.cursor/`, memory-bank, правила).  
Выгрузка конфигурации 1С (80k+ XML) — отдельный workflow (`getconfigfiles`, EDT).
