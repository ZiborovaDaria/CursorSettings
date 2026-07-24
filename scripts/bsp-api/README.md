# BSP API catalog (Hub)

Portable справочник **публичного программного интерфейса** БСП для агентов.

## Решение (CREATIVE B)

| Поле | Роль |
|---|---|
| `qualified_name` (`Модуль.Имя`) | точный ключ → locate тела в **текущей** КФ |
| `summary` | краткое описание → FTS / vector |
| `full_doc` | полный комментарий перед процедурой/функцией |

Тела функций **не** хранятся. Эталон экстракции ≠ обязательный path:line.

## Файлы

| Файл | Назначение |
|---|---|
| `VERSION.md` | версия БСП, дата, счётчики |
| `catalog.jsonl` | все карточки (machine) |
| `summaries.md` | таблица для FTS |
| `by-module/<Модуль>.md` | full_doc по модулям |
| `dense/` | **dense-индекс** (`vectors.npy`, `meta.jsonl`, `INDEX.md`) |

## Как искать (агент)

1. **Dense (рекомендуется по смыслу):**
   ```powershell
   python C:\1c-shared-patterns\scripts\Search-BspApiDense.py "прочитать реквизит по ссылке" --top 5 --category interface
   ```
   Модель: `qwen3-embedding:4b` (та же, что bsl-atlas / Ollama).
2. FTS fallback: `summaries.md` / `catalog.jsonl`
3. Карточка: `full_doc` (`--with-doc` или `by-module/…`)
4. Locate в проекте: Atlas / code-index / litecode по `Модуль.Имя`
5. ITS методика (опц.): naparnik `fetch_its` `bsp321doc`

Skill: `1c-ssl-patterns`.

## Обновление каталога + dense

```powershell
python C:\1c-shared-patterns\scripts\Extract-BspApi.py --cf-root C:\Cursor\UT25_85
python C:\1c-shared-patterns\scripts\Index-BspApiDense.py
# поиск:
python C:\1c-shared-patterns\scripts\Search-BspApiDense.py "фоновое задание с прогрессом"
```

Scope: модули из подсистемы `СтандартныеПодсистемы`, только `#Область ПрограммныйИнтерфейс*` + `Экспорт`.  
`*Переопределяемый` → `category: override` (не вызывать как API).

## Индексация (политика)

- **Да:** summary → FTS + **dense** (`qwen3-embedding:4b`)
- **Нет в embed:** full_doc, тела, archive_raw, единый vector всего Hub
- Lessons: без vector (index.md)

## Не цели

- Зеркало ITS / scraper bsp321doc
- Копия в agent-lessons
- MCP `1c-mcp_ssl_server` (legacy; тонкий MCP — только по отдельному approve)
