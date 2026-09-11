# Extent / Memory Bank — разнесение по контрагентам

Канон для всех проектов `C:\Cursor\*` с поставкой CFE/EPF/ERF клиентам.

## Структура

```text
Extent/
  <Контрагент>/          # имя папки = Desktop\расширения\<Контрагент>
    <ИмяРасширения>/     # XML-исходники
  _неразнесено/          # контрагент ещё не определён

memory-bank/
  tasks.md               # индекс + активный контрагент
  contractors/
    README.md
    <Контрагент>/
      tasks.md
      activeContext.md
      progress.md
    _неразнесено/
```

## Сдача версии

`Desktop\расширения\<Контрагент>\<Имя>_<версия>.cfe|.epf|.erf`

## Match с Desktop

Только точное имя артефакта: `{Имя}.cfe` / `{Имя}_X.Y.Z.cfe` (не подстрока).

## Правило агента

Новая задача → **спросить контрагента** (`memory-bank/contractors/README.md`).

## Установка в проект

1. Скопировать `templates/extent-contractors/README.md` → `Extent/README.md` (подставить список контрагентов проекта).
2. Скопировать `memory-bank/contractors/` из этого репо (или `templates/contractors/`).
3. В корневом `memory-bank/tasks.md` держать индекс, не свалку задач.

Эталон внедрения (2026-08-28): UT25_85, BP, KA, UNF, UNF12_261, UT22_92.
