---
name: esti-project
description: "Контекст проекта ЭСТИ — Управление фирмой-франчайзи 2.2.5.90 на базе УНФ 3.0.13.342. Используй при старте задачи, выборе расширения, ИБ, MCP или префикса объектов."
---

# Проект ЭСТИ — Управление фирмой-франчайзи

## Конфигурация
- Имя: `ЭСТИ_УправлениеФирмойФранчайзи_УправлениеНебольшойФирмой_CRM`
- Версия: `2.2.5.90`
- Базовая КФ: УНФ `3.0.13.342`
- Платформа: `8.5.1.1150`, режим совместимости КФ: `Version8_5_1`
- Выгрузка: `C:\Cursor\ESTI`
- Сайт: [estyuff.ru](https://estyuff.ru/)

## Информационная база
Источник истины: `infobasesettings.md` (не коммитить).

| Параметр | Значение |
|---|---|
| Файловая ИБ | `C:\Users\Admin\Documents\ESTI` |
| HTTP | `http://localhost/ESTI` |
| Пользователь | Admin |
| Пароль | 1 |

## Расширения
Каталог: `C:\Cursor\ESTI\Extent\` (создаётся при добавлении расширений).

Новые объекты: префикс **ESTI** (`PREFIX` в `.dev.env`), размещение в расширении (`NEW_OBJECTS_IN=extension`).

## MCP
См. `.cursor/MCP_QUICK_START.md` (кратко) и `.cursor/MCP_SETUP_ESTI.md`.
- **Locate BSL/метаданные**: `bsl-atlas-esti` (`http://localhost:8008/mcp`), правило `25-agent-bsl-atlas-esti.mdc`.
- **Edit BSL**: Serena. **ИБ**: `mcp-1c`. **Fallback**: `code-index` (`bsl-indexer`, `repo: "ESTI"`).
- **УНФ/БСП**: `1c-naparnik` → `config_name=УНФ`.
- Статус Atlas: `powershell -File .cursor/scripts/Get-BslAtlasIndexStatus-ESTI.ps1`.

## Политика
- Основную КФ не менять без явной команды.
- `zup-hr-api-reference` — не использовать (это ЗУП).
