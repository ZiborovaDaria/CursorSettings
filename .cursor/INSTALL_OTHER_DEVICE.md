# Установка ЭСТИ на новом устройстве

Полный чеклист: Cursor, MCP, память агента, litecode/Atlas. См. [RULES_INDEX.md](RULES_INDEX.md) · [INSTALL_ALL_PROJECTS.md](INSTALL_ALL_PROJECTS.md).

**Сначала общие шаги для всех КФ** (Hub + Playwright + User Rules Gate):  
[INSTALL_ALL_PROJECTS.md](INSTALL_ALL_PROJECTS.md) §1 → §1b → §1c · [docs/HUB_FPLUS_LITE.md](../docs/HUB_FPLUS_LITE.md).

**Пути (одинаковые на всех ПК):**

| Что | Путь |
|---|---|
| Workspace / выгрузка КФ | `C:\Cursor\ESTI` |
| Hub знаний | `C:\1c-shared-patterns` |
| Файловая ИБ | см. `infobasesettings.md` |
| HTTP | `http://localhost/ESTI` |
| MCP binaries | `C:\CursorMCP\` |
| Atlas index | `C:\bsl-atlas-indexes\ESTI` |
| Litecode data | `C:\bsl-litecode-data\ESTI` |
| Serena clone | `C:\Users\<user>\serena-main` (+ `uv`) |
| Serena logs / global cfg | `%USERPROFILE%\.serena\` |
| Serena launcher | `C:\Cursor\ESTI\.cursor\serena-mcp.cmd` (JDK 21 в PATH) |
| JDK для BSL LS | Microsoft OpenJDK **21+** (не 8, не 17) |
| Playwright skill | `%USERPROFILE%\.cursor\skills\1c-web-test` |
| Web scenarios | `tests/web/` (см. `tests/web/INSTALL.md`) |

---

## 1. Глобально (один раз на ПК)

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1   # если нет .cursor/export
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Скрипт ставит:
- `~/.cursor/rules` (24), `~/.cursor/skills` (99)
- `~/.cursor/scripts` (`sync-global-rules.ps1`, `sync-project-mcp.ps1`)
- `~/.cursor/templates`
- `.supercode/` (режимы Memory Bank)
- `.cursor/mcp.json` ← `mcp.profile.power.json` (или `-Profile LITE`)
- deps навыков: transcribe, md-to-docx (`Install-ESTI-SkillDeps.ps1`)

---

## 2. Настройки workspace ЭСТИ

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

Создаёт/обновляет (если ещё нет):
- `memory-bank/` — скелет Memory Bank (L0)
- `memory.md` — карта слоёв памяти L0–L3
- `handoffs/` — для `/handoff`
- `.supercode/` — режимы van/plan/implement/…
- `.vscode/extensions.json` — рекомендация `supercode.supercode-sh`
- синхронизацию `global-*.mdc` в `.cursor/rules/`

**Memory Bank (L0)** — файлы в `memory-bank/`:

| Файл | Назначение |
|---|---|
| `projectbrief.md` | Продукт, цели, опорные объекты |
| `productContext.md` | Контекст продукта |
| `techContext.md` | Платформа, MCP, скрипты |
| `systemPatterns.md` | Паттерны решений |
| `activeContext.md` | Текущий фокус |
| `progress.md` | Прогресс задач |
| `tasks.md` | Активная задача (ephemeral) |
| `reflection/` | Ретроспективы (`reflect-lesson`) |
| `archive/` | Архив завершённых задач |
| `creative/` | Creative phase |

В репозитории ESTI skeleton уже заполнен — на новом ПК после clone ничего дополнительно инициализировать не нужно, если папка есть.

---

## 3. Локальные файлы (вручную, не в git)

| Файл | Действие |
|---|---|
| **User Rules** | Текст из `USER-RULES.md` → Cursor Settings → Rules |
| **`.dev.env`** | Скопировать из [`.dev.env.example`](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.dev.env.example) — пути ИБ, платформа, `PREFIX=ESTI`, модели субагентов |
| **`infobasesettings.md`** | Создать локально: путь ИБ, HTTP, OData, `hs/mcp-1c` (шаблон — см. соседний файл в workspace) |
| **`mcp.local.json`** | Секреты mcp-1c / REST — из [example](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/mcp.local.json.example) |
| **`device_profile`** | В `00-esti-device-profile.mdc`: `POWER` (основной ПК) или `LITE` (слабый ПК) |

Расширение Cursor: **supercode.supercode-sh** (см. `.vscode/extensions.json`).

---

## 4. Информационная база и публикация

1. Файловая ИБ — путь из `infobasesettings.md` / `.dev.env` (`INFOBASE_PATH`).
2. Опубликовать на Apache: `http://localhost/ESTI`.
3. Проверка OData: `http://localhost/ESTI/odata/standard.odata/$metadata` (Basic Auth).
4. HTTP-сервис `hs/mcp-1c` — для `mcp-1c` (если 404 → метаданные через выгрузку / code-index).
5. Запуск 1С: `/N Admin /P <пароль>` — см. `21-agent-single-1c-launch.mdc`.

---

## 5. MCP — профиль POWER (по умолчанию)

После install: **Cursor → Settings → MCP → Reload**.

### 5.0 Грабли установки MCP (проверено 2026-07) — делать сразу, не чинить потом

| # | Компонент | Нельзя | Надо сразу |
|---|---|---|---|
| 1 | **litecode** | `up -d` без `ОтчетПоКонфигурации.txt`; после нового отчёта только `restart` | отчёт в `metadata/` → `up -d`; смена отчёта → `FULL_METADATA_RELOAD=true` + recreate; ждать `Load complete` |
| 2 | **litecode multi** | оставлять удалённые КФ (ZUP) в data/compose/mcp | только актуальные проекты; порты 6004–6015 без пересечений |
| 3 | **code-index** | поднять демон до полной индексации; путать с codegraph; забытый alias в `daemon.toml` | `daemon.toml` → offline `index` (`-f` если нет `index.db`) → `daemon run` → Reload MCP |
| 4 | **code-index** | ждать search, пока batch крутится | offline batch часами — норма; MCP search после `daemon status` = ready |
| 5 | **lean-ctx** | `npm i -g lean-ctx` (404); WSL MCP на Win-Cursor; pin `LEAN_CTX_DATA_DIR` в `.config` | **Native Windows:** `npm i -g lean-ctx-bin` → user `mcp.json` + hooks (§5.4a) |
| 6 | **lean-ctx** | `cargo install` / WSL MCP «потому что так на старом ПК» | WSL+proxy — только если native Win не стартует; иначе timeout 60с (§5.4a) |
| 7 | **naparnik** | пересоздавать из‑за unhealthy (GET 405) | POST OK = сервис жив; `review`/`modify` могут быть сломаны — не блокер |
| 8 | **serena** | Java 8/17 из Oracle `java8path`; прямой `uv … serena` без JDK 21 | JDK 21+ + `.cursor/serena-mcp.cmd` **до** Reload (см. §5.5) |
| 9 | **пути** | хардкод `C:\CursorMCP\` на LITE-ПК | смотреть `.dev.env` / `MCP_SETUP_ESTI.md` — на этом ПК бинарники в `C:\Users\Daria\…` |
| 10 | **после правок** | надеяться что Cursor подхватит сам | Reload конкретного MCP (lean-ctx / code-index / serena) |

Детали по пунктам — §5.3–5.5 ниже.

### 5.1 Обязательные серверы

| Сервер | Роль | Проверка |
|---|---|---|
| `bsl-atlas-esti` | Locate BSL/метаданные | `docker ps --filter name=bsl-atlas-esti` |
| `litecode` | Семантика, `get_access` (права) | `docker ps --filter name=1c-metacode-esti` |
| `code-index` | Fallback grep, repo **ESTI** | tool `health` |
| `serena` | Edit BSL | JDK **21+** + launcher §5.5 · dashboard без Failed init |
| `1c-naparnik` | check_1c_code, УНФ help | `:8007` |
| `lean-ctx` | ctx_read, ctx_knowledge | global `~/.cursor/mcp.json` |
| `mcp-1c` / `1c-rest-mcp` | Живая ИБ | HTTP / OData |
| `v8std` | Стандарты 1С | https |

Подробно: [MCP_QUICK_START.md](MCP_QUICK_START.md) · [MCP_ROUTER_ESTI.md](MCP_ROUTER_ESTI.md) · [MCP_TOOLS_MATRIX.md](MCP_TOOLS_MATRIX.md).

**Не использовать для BSL:** `codegraph` (индексирует XML, не BSL). Папку `.codegraph/` можно удалить.

### 5.2 bsl-atlas-esti

```powershell
cd C:\bsl-atlas-indexes\ESTI
docker compose up -d
ollama pull qwen3-embedding:4b    # embeddings для Chroma
powershell -File C:\Cursor\ESTI\.cursor\scripts\Get-BslAtlasIndexStatus-ESTI.ps1
```

Исходники индекса: `C:\Cursor\ESTI`. Пока Chroma < 100% — семантика через `metadatasearch` + `grep_body`.

### 5.3 litecode (пересборка под проект ЭСТИ)

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Prepare-LitecodeData-ESTI.ps1 -TargetPath C:\bsl-litecode-data\ESTI
```

Скрипт создаёт:
- junction `C:\bsl-litecode-data\ESTI\code` → `C:\Cursor\ESTI`
- каталог `metadata/`

**Обязательно до первого `up -d`** — отчёт по конфигурации (для `get_access` и графа прав):

Конфигуратор 1С → **Отчёт по конфигурации** → сохранить:

```
C:\bsl-litecode-data\ESTI\metadata\ОтчетПоКонфигурации.txt
```

Без этого файла metacode стартует, но права/`get_access` пустые или устаревшие.

Запуск контейнера:

```powershell
cd C:\Cursor\ESTI\.cursor\infra\litecode-esti
docker compose -f docker-compose.fast.yml up -d    # ~8 ГБ RAM
# или docker compose up -d                         # full + embedding, ~16 ГБ
```

**После замены/обновления `ОтчетПоКонфигурации.txt`** — недостаточно `docker compose restart`. Нужен полный reload метаданных:

```powershell
cd C:\Cursor\ESTI\.cursor\infra\litecode-esti
$env:FULL_METADATA_RELOAD='true'
docker compose -f docker-compose.fast.yml up -d --force-recreate 1c-metacode-esti
# после Load complete — убрать FULL_METADATA_RELOAD и вернуть обычный compose
```

Проверка готовности (не только TCP):

```powershell
docker logs 1c-metacode-esti 2>&1 | Select-String 'Load complete|ERROR|heartbeat'
```

Smoke в MCP `litecode`:

```json
{"op":"browse","category":"Documents"}
{"op":"get_access","target":"ЗаказПокупателя"}
```

`LOAD_ROLE_RIGHTS=true` в compose — обязательно для прав ролей.

**Мультипроект:** порты metacode не пересекать. Удалённые КФ (напр. ZUP) убрать из `C:\bsl-litecode-data\`, compose **и** mcp/daemon — иначе висячие порты и путаница alias.

| Проект | Порт metacode |
|---|---|
| ESTI | 6004 |
| SB | 6005 |
| KA | 6006 |
| UNF12_261 | 6008 |
| UT22_92 | 6010 |
| UT | 6012 |
| HRM | 6013 |
| UNF13_374 | 6015 |

Shared: `mcp-1c-helper` :8000, ES :9200, naparnik/`1c-ai-mcp` :8007.  
Шум парсера `Skipping invalid child_type: Операции` — штатный, не ошибка.

### 5.4 code-index (bsl-indexer)

**Не путать с `codegraph`.**

| Что | Путь (этот ПК / LITE) | Альтернатива POWER |
|---|---|---|
| Исходники | `C:\Users\Daria\code-index-mcp` ([GitHub](https://github.com/Regsorm/code-index-mcp) · [Инфостарт](https://infostart.ru/1c/tools/2677918/)) | — |
| Бинарник | `...\target\release\code-index.exe` | `C:\CursorMCP\code-index.exe` |
| `CODE_INDEX_HOME` | `...\target\release` | каталог с `daemon.toml` |
| Конфиг демона | `%CODE_INDEX_HOME%\daemon.toml` | — |
| Индекс проекта | `C:\Cursor\<PROJ>\.code-index\index.db` | — |

Alias repo в MCP = имя из `daemon.toml` (`ESTI`, `KA`, …), не путь.

**Порядок (иначе MCP → `daemon_offline` / `not_started` / зависание `initial_indexing 0/0`):**

1. Собрать/положить `code-index.exe`, задать `CODE_INDEX_HOME`.
2. Заполнить `daemon.toml`: все нужные `[[paths]]` (`path`, `language = "bsl"`, `alias`). Удалённые КФ **не** оставлять.
3. **Сначала офлайн-индексация, потом демон.** Демон с пустым/битым индексом зависает на ESTI `initial_indexing 0/0`, остальные `not_started`.
4. Новая база без `.code-index\index.db` — полная индексация `-f` обязательна.
5. Большие КФ (УНФ/ESTI ~60–75k файлов) — часы; в `daemon.toml` держать `max_concurrent_initial = 1`.
6. Пока идёт batch — `daemon status` недоступен = **нормально**; MCP search не ждать до конца очереди.

```powershell
$exe = 'C:\Users\Daria\code-index-mcp\target\release\code-index.exe'
& $exe daemon stop   # если был запущен
& $exe index --path C:\Cursor\UNF13_374 -f   # новая/битая — force
& $exe index --path C:\Cursor\ESTI -f
& $exe index --path C:\Cursor\SB             # уже есть db — инкремент
# … HRM UT UT22_92 UNF12_261 KA …
& $exe daemon run
& $exe daemon status
```

7. Cursor → **Reload MCP `code-index`**. Smoke: `health` / `search_function` по alias `ESTI`.

### 5.4a lean-ctx (Windows Cursor) — сразу правильно

**Канон на Windows (проверено 2026-07, ПК Daria):** native `lean-ctx-bin` + user MCP + user hooks.  
**WSL MCP** (`wsl.exe` → cargo binary → path-proxy) — только fallback, если native не стартует. Иначе типичный провал: `MCP error -32001: Request timed out` (~60 с на скан `/mnt/c/…`).

#### Порядок установки (не чинить потом)

```powershell
# 1) Пакет — имя lean-ctx-bin (НЕ lean-ctx — на npm 404)
npm install -g lean-ctx-bin
lean-ctx --version          # ожидаем 3.9.x+
where.exe lean-ctx          # %APPDATA%\npm\lean-ctx.cmd

# 2) Setup (hooks + rules + MCP snippet)
lean-ctx setup              # из Windows PowerShell / cmd, НЕ из WSL
# или точечно:
lean-ctx doctor --fix

# 3) Проверка единства стора CLI ↔ MCP
lean-ctx doctor             # нужен ✓ config parity · Summary N/N
```

#### User MCP — `%USERPROFILE%\.cursor\mcp.json`

```json
"lean-ctx": {
  "type": "stdio",
  "command": "C:/Users/<user>/AppData/Roaming/npm/lean-ctx.cmd",
  "autoApprove": [ "ctx_read", "ctx_shell", "ctx_search", "ctx_tree", "ctx_overview", "ctx", "…" ]
}
```

| Нельзя | Надо сразу |
|---|---|
| Копировать путь `C:/Users/Admin/…/lean-ctx.cmd` с другого ПК | Подставить **текущего** `%USERNAME%` / `%APPDATA%` |
| `"command": "wsl.exe", "args": ["-d","Ubuntu", … path-proxy]` на Win-Cursor | Native `.cmd` / `.exe` (см. выше) |
| `"env": { "LEAN_CTX_DATA_DIR": "C:\\Users\\…\\.config\\lean-ctx" }` | **Не пинить** DATA_DIR. CLI/hooks = `~\.local\share\lean-ctx`, config = `~\.config\lean-ctx\config.toml`. Pin в `.config` → doctor `✗ config parity`, observe/MCP пишут в разные сторы |
| `npm install -g lean-ctx` | `npm install -g lean-ctx-bin` |
| Ожидать зелёный MCP без Reload | Cursor → Settings → MCP → **Reload `lean-ctx`** (или Reload Window) |

Smoke handshake (до Reload): initialize MCP через `.cmd` должен ответить **<10 с**, не 60 с.

#### User hooks — `%USERPROFILE%\.cursor\hooks.json` (только Windows-путь)

Писать в `C:\Users\<user>\.cursor\hooks.json`. Hooks в `/home/…/.cursor/` Cursor Desktop **не видит**.

Эталон (observe + compression + deny):

```json
{
  "version": 1,
  "hooks": {
    "afterAgentResponse": [{ "command": "lean-ctx hook observe" }],
    "afterAgentThought": [{ "command": "lean-ctx hook observe" }],
    "afterMCPExecution": [{ "command": "lean-ctx hook observe" }],
    "afterShellExecution": [{ "command": "lean-ctx hook observe" }],
    "beforeReadFile": [{ "command": "lean-ctx hook observe" }],
    "beforeSubmitPrompt": [{ "command": "lean-ctx hook observe" }],
    "postToolUse": [{ "command": "lean-ctx hook observe" }],
    "preCompact": [{ "command": "lean-ctx hook observe" }],
    "sessionEnd": [{ "command": "lean-ctx hook observe" }],
    "sessionStart": [{ "command": "lean-ctx hook observe" }],
    "preToolUse": [
      {
        "command": "C:/Users/<user>/AppData/Roaming/npm/node_modules/lean-ctx-bin/bin/lean-ctx.exe hook rewrite",
        "matcher": "Shell"
      },
      {
        "command": "C:/Users/<user>/AppData/Roaming/npm/node_modules/lean-ctx-bin/bin/lean-ctx.exe hook deny",
        "matcher": "Grep|Glob"
      },
      {
        "command": "C:/Users/<user>/AppData/Roaming/npm/node_modules/lean-ctx-bin/bin/lean-ctx.exe hook redirect",
        "matcher": "Read"
      }
    ]
  }
}
```

| Грабля | Почему | Сразу |
|---|---|---|
| `doctor --fix` урезает hooks | setup пишет короткий набор (без полного observe) | После `--fix` **вернуть** полный observe-список + exe-пути в `preToolUse` |
| `lean-ctx hook …` без PATH в hook-env | Cursor hook spawn иногда не видит npm | Absolute path на `lean-ctx.exe` для rewrite/deny/redirect |
| Hooks с чужого ПК «как есть» | другой user / WSL / старая схема `redirect Read\|Grep` | Подставить своего user; deny Grep\|Glob + redirect Read (shadow) |

`config.toml` (`~\.config\lean-ctx\`):

```toml
tool_profile = "standard"
extra_roots = ["C:\\Cursor\\ESTI"]
allow_paths = ["C:\\Cursor\\ESTI", "C:\\Cursor", "C:\\Users\\<user>"]
```

Не раздувать `extra_roots` на весь `C:\Users\…` без нужды — медленный graph/index при старте.

#### Fallback: WSL + path-proxy (только если native не работает)

Симптомы native-fail: нет `.cmd`, crash бинарника, `rmcp`/`SseStream` при сборке. Тогда — `%USERPROFILE%\.cursor\LEAN_CTX_FIX_VAN.md` + `lean-ctx-path-proxy.py`.

| Ошибка WSL-режима | Причина | Сразу |
|---|---|---|
| `Request timed out` / initializing вечно | скан `/mnt/c/Cursor` + `/mnt/c/Users/…` ~60 с | Сузить `LEAN_CTX_WORKDIR` / `extra_roots` до `/mnt/c/Cursor/ESTI`; лучше — вернуться на native |
| `path escapes` / `…/C:/Cursor/…` | Win-пути в WSL MCP | path-proxy обязателен |
| Locks `.startup-maintenance.lock` / `.graph-idx-*.lock` | несколько окон Cursor + зависания | `pkill lean-ctx` в WSL, снять lock, один Reload |
| Hooks в WSL home | setup из bash WSL | Только Windows `%USERPROFILE%\.cursor\hooks.json` |

#### После установки — проверка

```powershell
lean-ctx doctor          # ✓ config parity, data dir = ~\.local\share\lean-ctx
lean-ctx --version
Test-Path $env:USERPROFILE\.cursor\hooks.json
# Cursor: Reload MCP lean-ctx → status ready → smoke ctx_read на файл в ESTI
```

В агенте: native `Shell`/`Read`/`Grep` → rewrite/deny/redirect (shadow); MCP tools `ctx_*` зелёные.

### 5.4b 1c-naparnik / shared :8007

- Docker health часто **unhealthy** (GET → 405), при этом **POST MCP работает** — не пересоздавать контейнер из‑за красного health.
- Рабочие: `check_1c_code`, `onec_help`, `explain_1c_syntax`, `config_help`, `its_help`, `ask_1c_ai`, …
- Известный баг: `review_1c_code` / `modify_1c_code` → «API вернул tool_calls повторно…» — не блокер установки; review → `check_1c_code` + v8std.

### 5.5 Serena (сделать **до** Reload MCP)

Без этого шага dashboard покажет `Failed Task-1:init_project_services`, а символьные tools (find_symbol / overview / diagnostics) не поднимутся.

#### 5.5.1 Java 21+ для BSL Language Server

Serena для ESTI стартует LSP `bsl` (JAR `bsl-language-server` ≥0.29). Нужен **JDK 21+** первым в `PATH`.

**Типичный провал (уже ловили на ПК):**

```text
Java 21+ is required for BSL Language Server, but
'C:\Program Files (x86)\Common Files\Oracle\Java\java8path\java.EXE' is Java 8
```

Oracle `java8path` часто стоит **раньше** Axiom/Temurin 17 в Machine PATH → Serena берёт Java 8 через `shutil.which("java")`.  
AxiomJDK **17** тоже мало — нужен именно **21+**.

**Плагин JetBrains не чинит Cursor.** Баннер `Ready to accept connections from Serena` / Serena JetBrains Plugin — только для IntelliJ/Rider + `language_backend: JetBrains`. В Cursor остаёмся на LSP.

**Поставить JDK 21 (один раз на ПК):**

```powershell
winget install --id Microsoft.OpenJDK.21 -e --accept-package-agreements --accept-source-agreements
# альтернатива: EclipseAdoptium.Temurin.21.JDK

# путь после install (версия в имени папки может отличаться):
$jdk = (Get-ChildItem 'C:\Program Files\Microsoft' -Directory | Where-Object Name -like 'jdk-21*').FullName
# пример: C:\Program Files\Microsoft\jdk-21.0.11.10-hotspot

[Environment]::SetEnvironmentVariable('JAVA_HOME', $jdk, 'User')
$bin = Join-Path $jdk 'bin'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$parts = @($userPath -split ';' | Where-Object { $_ -and $_ -ne $bin -and $_ -notmatch 'Oracle\\Java\\java8path' })
[Environment]::SetEnvironmentVariable('Path', ($bin + ';' + ($parts -join ';')).TrimEnd(';'), 'User')

# проверка в НОВОМ терминале:
where.exe java
java -version   # должно быть openjdk 21.x, НЕ 1.8
```

Machine PATH после winget обычно уже кладёт `jdk-21*\bin` первым; User PATH + launcher ниже — страховка, если Cursor стартовал со старым env.

#### 5.5.2 Launcher Serena (обязателен на Windows с Oracle Java 8)

Файл `.cursor/serena-mcp.cmd` (локальный, подставить свои пути `uv` / `serena-main` / `JAVA_HOME`):

```bat
@echo off
REM BSL LS: Java 21+ must beat Oracle java8path
set "JAVA_HOME=C:\Program Files\Microsoft\jdk-21.0.11.10-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"
"C:\Users\Daria\.local\bin\uv.exe" run --directory "C:\Users\Daria\serena-main" serena start-mcp-server --context ide --project "%~1"
```

В `.cursor/mcp.json` (или профиле LITE/POWER после merge):

```json
"serena": {
  "type": "stdio",
  "command": "C:\\Cursor\\ESTI\\.cursor\\serena-mcp.cmd",
  "args": ["${workspaceFolder}"]
}
```

Не вызывать `uv … serena start-mcp-server` напрямую без префикса JDK 21 — снова поймаешь Java 8.

Клон Serena: `C:\Users\<user>\serena-main` (или путь из install). `uv` — `~\.local\bin\uv.exe`.

#### 5.5.3 После установки — Reload и ожидание init

1. Cursor → Settings → MCP → **Restart** у `serena` (или Reload Window).
2. Dashboard: очередь `Task-1:init_project_services` — **норма**. На ESTI может занять **много минут** (сбор `.gitignore` по огромному дереву) + ~10–15 с старт BSL LS.
3. Успех в логе `~\.serena\logs\<date>\mcp_*.txt`:

```text
Language server startup (language=bsl) completed
Task-1:init_project_services completed
```

Провал снова с `Java 8` / `Java 17` → launcher/`JAVA_HOME` не подхватились; проверь `where java` **в env процесса MCP**, не только в PowerShell.

#### 5.5.4 Dashboard: «статистика сбрасывается» — не баг

- Tool Usage / Last Execution живут **только в RAM** текущего процесса Serena (`ToolUsageStats` → dict, без записи на диск).
- Каждый Restart MCP = новый процесс = «No tool usage stats collected yet» + снова `init_project_services`.
- История вызовов: `C:\Users\<user>\.serena\logs\` (файлы `mcp_*.txt`, искать `_log_tool_application` / `Task-*:…Tool`).
- Memories проекта: `C:\Cursor\ESTI\.serena\memories\` (это не usage stats).
- Кэш LSP: `C:\Cursor\ESTI\.serena\cache\bsl\` — ускоряет повторный init, но не отменяет его.

#### 5.5.5 Smoke после зелёного init

В Cursor через агента (или MCP tools):

| Tool | Ожидание |
|---|---|
| `initial_instructions` | project ESTI, language `bsl` |
| `get_symbols_overview` на `Extent/SchetNDS/tools/extension_print_service.bsl` | список Method |
| `get_diagnostics_for_file` на тот же файл | diagnostics от `bsl-language-server` |
| `find_symbol` / `search_for_pattern` | hits |

`find_referencing_symbols` / `find_implementations` для BSL часто пустые — лимит LS, не признак поломки.

LSP-tools на ESTI могут идти **~30–40 с** из‑за `sync_file_system_changes` по большому дереву — не рвать MCP посередине серии вызовов.

### 5.6 Живая ИБ (mcp-1c, REST)

- `mcp-1c.exe` → `http://localhost/ESTI/hs/mcp-1c`
- Пароль — только в `mcp.local.json`, не в git
- REST MCP: при ошибке auth → `powershell -File .cursor\scripts\patch-1c-rest-mcp-noauth.ps1`

### 5.7 Память агента (L1–L2)

| Слой | Где | Инициализация |
|---|---|---|
| L1 episodic | lean-ctx `ctx_knowledge` | автоматически при `capture-error` / `reflect-lesson` |
| L2 invariant | `.serena/memories/` | `read_memory` → `mem:core`, `pitfalls/cfe_bsl` |
| L3 rules | `.cursor/rules/*.mdc` | через Spread / install |

Корневая карта: `memory.md`. Конвейер ошибок: `33-agent-error-learning-pipeline.mdc`.

---

## 6. Навык проекта

Workspace-навык: `.cursor/skills/esti-project/SKILL.md` (контекст ЭСТИ УНФ).

---

## 7. Проверка

```powershell
# Java 21 раньше Oracle 8 (иначе Serena/BSL LS упадёт)
where.exe java
java -version

powershell -File .cursor\scripts\Test-ESTI-MCPStack.ps1
powershell -File .cursor\scripts\Get-BslAtlasIndexStatus-ESTI.ps1
```

В Cursor: Settings → MCP → `serena` зелёный · dashboard без Failed `init_project_services` · `/doctor` · тестовая dev-задача → caveman · review → связный русский.

**Чеклист анти-регрессий MCP (с этого ПК):**

| Симптом | Что сделать сразу (не «потом чинить») |
|---|---|
| `init_project_services` Failed + Java 8/17 | §5.5.1–5.5.2: JDK 21 + `serena-mcp.cmd` + Restart Serena |
| Баннер JetBrains Plugin | Игнор в Cursor; не ставить ради фикса |
| Dashboard пустой Tool Usage после рестарта | Норма (§5.5.4); смотри `~\.serena\logs` |
| Долгий init / tool ~30–40 с | Норма для ESTI; дождаться completed в логе |
| Serena `Not connected` mid-session | Restart MCP Serena; не гонять десятки LSP-tools подряд без пауз |
| lean-ctx `Request timed out` / loading вечно | §5.4a: native `lean-ctx-bin`, не WSL MCP; Reload |
| lean-ctx npm 404 `lean-ctx` | Ставить `lean-ctx-bin` |
| doctor `✗ config parity` | Убрать `LEAN_CTX_DATA_DIR` из user `mcp.json`; data = `~\.local\share\lean-ctx` |
| Hooks «поставил», Cursor не жмёт shadow | Windows `~\.cursor\hooks.json` + absolute `lean-ctx.exe` в `preToolUse` |

---

## 8. Профиль LITE (слабый ПК)

1. `device_profile: LITE` в `00-esti-device-profile.mdc`
2. `Install-ESTI-OnNewDevice.ps1 -Profile LITE` или merge `mcp.profile.lite.json` → `mcp.json`
3. Без Atlas/Ollama — только litecode + code-index
4. Полная инструкция: [MCP_LITE_DEVICE.md](MCP_LITE_DEVICE.md)

---

## 9. Профили MCP (справочно)

| Файл | Назначение |
|---|---|
| `mcp.profile.power.json` | Шаблон POWER → `mcp.json` |
| `mcp.profile.lite.json` | Шаблон LITE |
| `mcp.local.json.example` | [GitHub](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/mcp.local.json.example) → `mcp.local.json` |

Активный `mcp.json` не в git — создаётся install-скриптом.

---

## 10. Обновление настроек

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1   # если export удалён локально
powershell -File .cursor\scripts\Export-CursorSettings.ps1
powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
git add -A; git commit -m "chore: sync cursor"; git push
powershell -File .cursor\scripts\Remove-LocalDistributionBundle.ps1        # опционально после push
```

На втором ПК: `git pull` → `Install-ESTI-OnNewDevice.ps1` → `Install-Project-OnNewDevice.ps1` → Reload MCP → при необходимости `Prepare-LitecodeData-ESTI.ps1` + docker.

---

## 11. Что не нужно в ежедневной работе

| Путь | Где хранится | Восстановление |
|---|---|---|
| `.cursor/export/` | GitHub | `Restore-DistributionBundleFromGit.ps1` |
| `.cursor/shared-bundle/` | GitHub | то же |
| `.dev.env.example`, `mcp.local.json.example` | GitHub | то же |
| `.codegraph/` | локальный мусор | удалить |

Рабочие: `.cursor/rules/`, `mcp.json`, `memory-bank/`, `mcp.profile.*.json`, `projects.manifest.json`.
