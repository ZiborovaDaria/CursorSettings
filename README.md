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

## Документация

| Файл | Назначение |
|---|---|
| [INSTALL_OTHER_DEVICE.md](.cursor/INSTALL_OTHER_DEVICE.md) | Установка на втором устройстве |
| [RULES_INDEX.md](.cursor/RULES_INDEX.md) | Карта правил и навыков |
| [USER-RULES.md](USER-RULES.md) | Стиль ответа (caveman) |
| [CURSOR_SYNC.md](.cursor/CURSOR_SYNC.md) | Синхронизация между ПК |

## Примечание

Этот коммит содержит **настройки агента** (`.cursor/`, memory-bank, правила).  
Выгрузка конфигурации 1С (80k+ XML) — отдельный workflow (`getconfigfiles`, EDT).
