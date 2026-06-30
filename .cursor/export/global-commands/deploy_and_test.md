# Развёртывание и тестирование (проект ЭСТИ)

## Предусловия

1. Файл **`infobasesettings.md`** — ИБ с пользователем **Admin** / **1** (команды с `/N Admin /P 1`).
2. Платформа: `C:\Program Files\1cv8\8.5.1.1150\bin\1cv8.exe` (см. `.dev.env` → `PLATFORM_VERSION`).
3. Корень выгрузки: **`C:\Cursor\ESTI`** (основная КФ) и при необходимости **`C:\Cursor\ESTI\Extent\<ИмяРасширения>`** (расширение).

## Загрузка конфигурации в ИБ

**Шаг 1 — загрузка из файлов:**

```powershell
$V8 = 'C:\Program Files\1cv8\8.5.1.1150\bin\1cv8.exe'
$IB = 'C:\Users\Admin\Documents\ESTI'
$Root = 'C:\Cursor\ESTI'
$Log = 'C:\Cursor\ESTI\logs\Update.log'
New-Item -ItemType Directory -Force -Path (Split-Path $Log) | Out-Null
& $V8 DESIGNER /F $IB /N Admin /P 1 /DisableStartupMessages /LoadConfigFromFiles $Root /Out $Log
```

Прочитать `$Log` на ошибки. **Дождаться завершения процесса конфигуратора.**

**Пауза 30 с** (лицензии 1С, один экземпляр) — см. `@rules/21-agent-single-1c-launch.mdc`, скрипт `.cursor/scripts/Wait-1cLicenseSlot.ps1`:

```powershell
. "C:\Cursor\ESTI\.cursor\scripts\Wait-1cLicenseSlot.ps1"
Wait-1cLicenseSlot
```

**Шаг 2 — обновление структуры БД:**

```powershell
& $V8 DESIGNER /F $IB /N Admin /P 1 /DisableStartupMessages /UpdateDBCfg -Dynamic+ -SessionTerminate force /Out $Log
```

Для **только расширения** добавьте к загрузке: `/LoadConfigFromFiles ...\Extent\<ИмяРасширения> -Extension <ИмяВИБ>`.

## Тестирование UI

URL из `infobasesettings.md` (по умолчанию **`http://localhost/ESTI`**).

- Использовать **`user-puppeteer-real-browser`** или **`user-screenshot`**.
- При вводе в формы — **human-like typing** с задержками; поля — через TAB.

## Логи

Каталог логов: `C:\Cursor\ESTI\logs\` (создаётся при первом запуске).
