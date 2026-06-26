---
name: cfe-load-hang-recovery
description: >-
  Диагностика и восстановление зависания загрузки расширения 1С (CFE) из XML
  на 100% в конфигураторе. Использовать при «вечной загрузке», LoadConfigFromFiles,
  пустом расширении в ИБ, битой оболочке после неудачной загрузки, повторяющихся
  сбоях расширения из Extent/.
---

# Восстановление зависания загрузки расширения (CFE)

## Когда применять

- Конфигуратор: **«Загрузка объектов конфигурации» → 100% → «Завершение загрузки»** и дальше тишина.
- То же при `/LoadConfigFromFiles` из командной строки (**>60–90 с**, код процесса **-1**).
- Повторяется после «удаления» расширения в UI — **типичный регресс**.

Сначала прочитать **`powershell-windows`**. Для общих операций CFE — **`1c-metadata-manage`** → `docs/cfe-manage.md`.

## Причины (проверять все)

| # | Причина | Признак / действие |
|---|---------|-------------------|
| A | **Битая оболочка в ИБ** | В базе расширение есть, но почти пустое (часто только `Language`, пустой `NamePrefix`, нет документов/модулей) → `/DeleteCfg -Extension` |
| B | **Ошибки в файлах XML/BSL** | Неверные перехватчики, XML заимствования не через `cfe-borrow` → `cfe-validate` + `cfe-verify-interceptors` |
| C | **Заимствование без `PropertyState`** | В XML документа с `Ext\ManagerModule.bsl` или `Ext\ObjectModule.bsl` нет **`PropertyState` → `ManagerModule`/`ObjectModule` → `Extended`** |
| D | **`ConfigDumpInfo.xml`** | Фиктивные `configVersion` / UUID не из borrow → удалить файл |
| E | **Крупные объекты в одном прогоне** | Большой `CommonTemplate` (MXL) и/или `CommonModule` (BSL) в одном `LoadConfigFromFiles` → **поэтапная** загрузка (см. ниже) |

Часто **A + B** (иногда **+ C/D/E**) вместе: первая неудачная загрузка оставляет оболочку, следующие попытки зависают при слиянии.

### Поэтапная загрузка (крупный CFE)

Если полный каталог `Extent\…` с макетом MXL (~200+ KB) и общим модулем зависает на 100% (>120–300 с) при CLI/UI `LoadConfigFromFiles`:

1. В `Configuration.xml` **временно** убрать из `ChildObjects` строки **`CommonTemplate`** и **`CommonModule`** (файлы на диске **не удалять**).
2. `cfe-recover.ps1 -Action Recover` — ожидание **~10–30 с**, exit **0**.
3. В конфигураторе: загрузить/добавить общий модуль и макет **по одному** из `CommonModules\…` и `CommonTemplates\…\Ext\Template.xml` (сравнить/добавить).
4. Вернуть объекты в `Configuration.xml` для репозитория (целевой состав метаданных).

Проверено на ESTI (`Extent\SchetNDS`); применимо к любому расширению SB с тяжёлым MXL+модулем.

---

## Быстрый алгоритм (15–20 мин)

```text
[ ] 1. Закрыть все 1cv8 (конфигуратор, предприятие, фоновые DESIGNER)
[ ] 2. Диагностика ИБ: cfe-recover.ps1 -Action Diagnose
[ ] 3. Если оболочка битая → Delete (только /DeleteCfg, не DeleteCfgExtension)
[ ] 4. Диагностика файлов: cfe-validate + grep перехватчиков (ниже)
[ ] 5. Исправить файлы или пересобрать каталог (раздел «Пересборка»)
[ ] 6. Load из CLI; успех = код 0 и <30 с для малого расширения
[ ] 7. В конфигураторе: обновить конфигурацию БД, включить расширение
```

### Скрипт проекта

| Файл | Назначение |
|------|------------|
| `scripts/cfe-recover.ps1` | Diagnose / Delete / Load / Recover |
| `scripts/cfe-verify-interceptors.ps1` | Сверка `&Перед`/`&После`/`&ИзменениеИКонтроль` с типовым модулем в `C:\Cursor\SB` |
| `scripts/cfe-risk-patterns.txt` | Строки для поиска в BSL (UTF-8); при необходимости дополнить |

```powershell
powershell.exe -NoProfile -File ".cursor/skills/cfe-load-hang-recovery/scripts/cfe-recover.ps1" `
  -ExtensionPath "C:\Cursor\SB\Extent\ChangeNum" `
  -ExtensionName "РеализацияЗаменаНомера" `
  -InfoBasePath "C:\Users\Daria\Documents\InfoBase11" `
  -Action Diagnose

# Полный цикл: удалить из ИБ → загрузить файлы
# -Action Recover
```

Параметры ИБ/платформы — из `infobasesettings.md` и `.dev.env` (`PLATFORM_VERSION`). **Без** `/N` `/P` для проекта SB.

---

## Шаг 1 — диагностика ИБ (оболочка)

**Команда удаления (единственная рабочая в 8.5):**

```powershell
$V8 = "C:\Program Files\1cv8\8.5.1.1150\bin\1cv8.exe"
$IB = "C:\Users\Daria\Documents\InfoBase11"
& $V8 DESIGNER /F $IB /DisableStartupMessages /DeleteCfg -Extension "ИмяРасширения"
```

**Не использовать** `/DeleteCfgExtension` — часто код 1 без удаления.

**Проверка, что расширение в ИБ:**

```powershell
$dump = "$env:TEMP\cfe-dump-check"
New-Item -ItemType Directory -Path $dump -Force | Out-Null
& $V8 DESIGNER /F $IB /DisableStartupMessages /DumpConfigToFiles $dump -Extension "ИмяРасширения"
```

Интерпретация `Configuration.xml` из дампа:

| В `ChildObjects` | Вердикт |
|------------------|---------|
| Только `Language` | **Битая оболочка** — DeleteCfg, затем чистая загрузка |
| Есть документы, модули, роль, префикс в Properties | Оболочка живая — искать причину в файлах (шаг 2) |

Пустой `<NamePrefix/>` при ожидаемом префиксе — признак битой оболочки.

---

## Шаг 2 — диагностика файлов расширения

### 2.1 Валидация структуры

```powershell
powershell.exe -NoProfile -File ".cursor/skills/1c-metadata-manage/tools/1c-cfe-manage/scripts/cfe-validate.ps1" `
  -ExtensionPath "C:\Path\To\Extent\MyExt"
```

`0 errors` — необходимо, но **недостаточно** (не ловит битые перехватчики и битый borrow-XML).

### 2.1a Проверка перехватчиков против типовика

```powershell
powershell.exe -NoProfile -File ".cursor/skills/cfe-load-hang-recovery/scripts/cfe-verify-interceptors.ps1" `
  -ExtensionPath "C:\Cursor\SB\Extent\ChangeNum" `
  -ConfigPath "C:\Cursor\SB"
```

Exit **1** — не грузить в ИБ до исправления. Встроено в `cfe-recover.ps1 -Action Diagnose`.

### 2.2 Опасные перехватчики в BSL

**Правило проекта (always):** `@rules/1c-extensions-change-control.mdc` — раздел **«Перехватчики: только процедуры, которые есть в типовике»**. Агент **не должен** предлагать `&После("ПриУстановкеНовогоНомера")` для **РеализацияТоваровУслуг** в БП 3.0.

Проверить **все** `*.bsl` расширения:

```text
&ИзменениеИКонтроль(
&После("
&Перед("
```

| Проблема | Действие |
|----------|----------|
| `&После("ПриУстановкеНовогоНомера")` у документа **без** этого обработчика в типовике | Удалить; логику перенести в `&После("ПередЗаписью")` |
| `&ИзменениеИКонтроль` с полной копией типовой функции | Убрать; заменить на `&После` / узкий сценарий в модуле объекта |
| Перехват несуществующего метода | Сверить с типовым модулем в выгрузке КФ или `grep` по `C:\Cursor\SB` |

**Правило проекта:** в типовых модулях только `&Перед` / `&После` / `&ИзменениеИКонтроль` — см. `@rules/1c-extensions-change-control.mdc`. Для «копии номера в СФ» достаточно `&После("ПередЗаписью")` в модуле объекта счёта-фактуры.

### 2.2a Язык `Language.Русский` после `cfe-init`

`cfe-init` подставляет `ExtendedConfigurationObject` = `00000000-0000-0000-0000-000000000000` — при **проверке применимости** ошибка «ОбъектРасширяемойКонфигурации не совпадает». Взять UUID из `Languages/Русский.xml` **типовой КФ** (у БП 3.0: `db4a9ccb-9ef5-4b3c-8577-b6fe5db1b62e`) или из рабочего расширения (`Extent/FTP`). Затем перезагрузить расширение из файлов.

### 2.3 XML заимствованных объектов

Документы/справочники с `ObjectBelonging=Adopted` — **только** через borrow:

```powershell
powershell.exe -NoProfile -File ".cursor/skills/1c-metadata-manage/tools/1c-cfe-manage/scripts/cfe-borrow.ps1" `
  -ExtensionPath "C:\Path\To\Extent\MyExt" `
  -ConfigPath "C:\Cursor\SB" `
  -Object "Document.ИмяДокумента"
```

После borrow — добавить в XML документа `PropertyState` для расширяемого модуля:

```xml
<xr:PropertyState>
  <xr:Property>ObjectModule</xr:Property>
  <xr:State>Extended</xr:State>
</xr:PropertyState>
```

Для **`Ext\ManagerModule.bsl`** — то же с **`ManagerModule`** вместо `ObjectModule`.

### 2.4 ConfigDumpInfo.xml

- Фиктивные `configVersion` (`a1b2c3…`) и UUID документов **не по borrow** → удалить файл или пересчитать после успешной загрузки (`-configDumpInfoOnly` при дампе из ИБ).
- Рабочая загрузка **возможна без** `ConfigDumpInfo.xml` — при сомнении убрать и загрузить заново.

### 2.5 Старый корень Configuration

Смена только `Configuration/@uuid` в файлах **не лечит** зависание, если имя расширения в ИБ то же и оболочка бита. Сначала **DeleteCfg**, потом файлы.

---

## Шаг 3 — пересборка каталога (если правки не помогают)

Минимальная «чистая» пересборка без смены имени расширения:

1. `cfe-init.ps1` во временный каталог `_rebuild` (то же `Name`, `NamePrefix`, `Purpose`).
2. `cfe-borrow.ps1` для всех заимствованных объектов из `C:\Cursor\SB`.
3. Скопировать **только** собственные объекты: `CommonModules/`, `Documents/**/Ext/*.bsl`, `Roles/**/Rights.xml`.  
   **Важно:** BSL — в `Documents\<Имя>\Ext\ObjectModule.bsl`, не в `Documents\<Имя>\ObjectModule.bsl`. При копировании: `Copy-Item ...\Ext ...\Ext -Recurse`, не содержимое `Ext` в корень документа.
4. В `Configuration.xml` — `ChildObjects` в порядке: Language, Role, CommonModule, Document, …
5. **Без** `ConfigDumpInfo.xml`.
6. Заменить содержимое рабочего каталога `Extent/...` (сохранить `tz*.md` при необходимости).
7. `DeleteCfg` + `LoadConfigFromFiles`.

---

## Шаг 4 — критерий успеха

| Проверка | Ожидание |
|----------|----------|
| CLI Load | Exit **0**, время **<30 с** (малое расширение, локальная ИБ) |
| Дамп после загрузки | `ChildObjects`: язык, роль, общие модули, заимствованные документы |
| Конфигуратор | Загрузка из файлов без зависания на 100% |
| Префикс | В свойствах расширения заполнен `NamePrefix` (не пустой) |

Код **-1** и **>90 с** — считать зависанием; убить `1cv8`, вернуться к шагу 1.

---

## Типичные ловушки (проект SB)

1. **Папка для загрузки** — каталог с `Configuration.xml` (например `Extent\ChangeNum`), не родитель `Extent`.
2. **Параллельный конфигуратор** на ту же ИБ — блокировка/псевдо-зависание.
3. **Два расширения с одним префиксом** (`ЗамНомера_`) — удалить тестовые (`ЗаменаНомераТест` и т.п.).
4. **Удаление в UI не сработало** — всегда подтверждать через `Diagnose` (дамп в `%TEMP%`).
5. **Имя в `-Extension`** должно совпадать с `<Name>` в `Configuration.xml`, не с синонимом.

---

## Связанные материалы

- `docs/cfe-manage.md` — borrow, validate, init (скилл `1c-metadata-manage`)
- `@rules/1c-extensions-change-control.mdc` — выбор аннотаций
- `@rules/1c-project-sb.mdc` — пути ИБ, платформа
- `infobasesettings.md` — каталог ИБ (не в git)
