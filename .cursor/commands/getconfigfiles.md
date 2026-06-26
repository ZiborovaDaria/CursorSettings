# Выгрузка объектов из ИБ в репозиторий (проект ЭСТИ)

Пути и платформа — из `infobasesettings.md` и `.dev.env`.

**Шаг 1 — выгрузка по списку:**

```powershell
$V8 = 'C:\Program Files\1cv8\8.5.1.1150\bin\1cv8.exe'
$IB = 'C:\Users\Admin\Documents\ESTI'
$Root = 'C:\Cursor\ESTI'
$Log = 'C:\Cursor\ESTI\logs\dump.log'
New-Item -ItemType Directory -Force -Path (Split-Path $Log) | Out-Null
& $V8 DESIGNER /F $IB /N Admin /P 1 /DisableStartupMessages /DumpConfigToFiles $Root -listFile "$Root\repoobjects.txt" /Out $Log
```

Выгружать **в текущий каталог** `C:\Cursor\ESTI`, без вложенного подкаталога.

Перед выгрузкой заполнить **`repoobjects.txt`** (MCP: `get_metadata_tree`, `get_object_structure`).
