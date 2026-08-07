---
name: 1c-ssl-patterns
description: "SSL/БСП: поиск публичного API по смыслу (Hub bsp-api) и locate тела в текущей КФ. Use when working with standard library — users, files, print, background jobs, email, common utilities."
---

# 1C SSL/БСП Subsystems Reference

Каталог публичного ПИ БСП (portable): `C:\1c-shared-patterns\playbooks\bsp-api\`  
CREATIVE B: `summary` для поиска, `full_doc` в карточке, тело — locate в **текущей** КФ по `Модуль.Имя`.

## When to Use

- Работа с пользователями и правами доступа
- Файлы, печать, фон/прогресс, email
- Общие утилиты (реквизиты, структуры, строки)
- Перед написанием «своей» утилиты — проверить БСП

## Core Principle

**ВСЕГДА проверяй, есть ли решение в БСП, прежде чем писать свой код.**

## Workflow (вместо 1c-mcp_ssl_server)

1. **Dense по смыслу** (модель bsl-atlas: `qwen3-embedding:4b` / Ollama):
   ```powershell
   python C:\1c-shared-patterns\scripts\Search-BspApiDense.py "значение реквизита" --top 5 --category interface
   ```
   Индекс: `playbooks/bsp-api/dense/` (после `Index-BspApiDense.py`).
2. **Карточка** — `qualified_name` + `--with-doc` или `by-module/<Модуль>.md`
3. **Locate в текущей КФ** — Atlas / code-index / litecode по `Модуль.Имя`
4. **Методика ITS** (опц.) — naparnik `fetch_its` id=`bsp321doc`
5. **Только потом** свой код

Примеры: «фоновое задание прогресс», «значение реквизита», «копирование структуры», «печатная форма».

## Refresh каталога + dense

```powershell
python C:\1c-shared-patterns\scripts\Extract-BspApi.py --cf-root C:\Cursor\UT25_85
python C:\1c-shared-patterns\scripts\Index-BspApiDense.py
```

См. `playbooks/bsp-api/VERSION.md`, `README.md`.

## Key SSL Modules

| Модуль | Назначение |
|--------|-----------|
| **ОбщегоНазначения** | ЗначениеРеквизитаОбъекта, ЗначенияРеквизитовОбъектов, КопироватьРекурсивно, СообщитьПользователю |
| **ОбщегоНазначенияКлиентСервер** | Проверки, структуры, массивы |
| **СтроковыеФункцииКлиентСервер** | Форматирование, подстановка параметров |
| **Пользователи** | Текущий пользователь, роли |
| **РаботаСФайлами** | Присоединенные файлы |
| **УправлениеПечатью** | Печатные формы |
| **ДлительныеОперации** | ВыполнитьВФоне, ОжидатьЗавершение |
| **ВерсионированиеОбъектов** | История изменений |
| **РаботаСПочтовымиСообщениями** | Email |

`*Переопределяемый` — category `override`, не вызывать из прикладного кода как API.

## Разграничение MCP

| Задача | Инструмент |
|--------|-----------|
| БСП по смыслу | Hub `bsp-api` (summary) + skill этот |
| Тело/сигнатура в КФ | Atlas / code-index / litecode |
| Методика БСП / ITS | naparnik `fetch_its` (`bsp321doc`) |
| Стандарты | v8std |
| API платформы | 1c-syntax-helper |

**Не использовать:** отсутствующий `1c-mcp_ssl_server` / `search_ssl` (legacy).
