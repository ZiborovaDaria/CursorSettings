# Установка УТ 11.5.25.85 на новом устройстве

Проект: **UT25_85** · путь: `C:\Cursor\UT25_85`  
Hub знаний: **`C:\1c-shared-patterns`** (junction: `C:\Cursor\1c-shared-patterns`)

Глобальные настройки Cursor (один раз на ПК): см. [INSTALL_ALL_PROJECTS.md](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/INSTALL_ALL_PROJECTS.md)  
или локально: `C:\Cursor\ESTI\.cursor\INSTALL_ALL_PROJECTS.md`.

---

## 0. Что обязательно на новом ПК (карта)

| Компонент | Зачем | Куда |
|---|---|---|
| Cursor + User Rules snippet | Hub Gate / `KB:` | Settings → Rules |
| `~/.cursor/skills` | 1С skills + Playwright skill | через Install-ESTI / Sync |
| `C:\1c-shared-patterns` | база паттернов + agent-lessons + sync pack | отдельный каталог / junction |
| `C:\Cursor\UT25_85` | workspace УТ | git / robocopy |
| Node 18+ + Chrome/Edge | Playwright e2e | система |
| skill `1c-web-test` + npm playwright | веб-автотесты 1С (регресс) | `~\.cursor\skills\1c-web-test` |
| skill `playwright-cli` + `@playwright/cli` | разведка UI (все проекты) | `~\.cursor\skills\playwright-cli` |
| ИБ + веб-публикация | runtime / web tests | локально (не в git) |

---

## 1. Глобальные настройки Cursor (один раз)

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Ставит базу `~/.cursor/rules`, `~/.cursor/skills`, scripts, templates.

**Важно:** длинный `shared-1c-pattern-reuse.mdc` в `~/.cursor/rules` **не** использовать как SoT.  
Протокол Hub — `hub-gate.mdc` в проекте + skills (см. §3). Sync удаляет устаревший user-rule reuse при установке agent pack.

### 1.1. User Rules (обязательно для Hub Gate)

В Cursor **Settings → Rules → User Rules** вставить текст из:

```text
C:\1c-shared-patterns\cursor-addons\user-rules\hub-gate-snippet.md
```

Затем **Reload Window**.

Без этого gate может не сработать в Agents Window / если project rules не подтянулись.

---

## 2. База знаний Hub (`1c-shared-patterns`) — обязательно

Это общий SoT для **всех** КФ в `C:\Cursor`, не только УТ.

### 2.1. Перенести каталог

Минимум (лёгкий перенос):

```text
C:\1c-shared-patterns\
  catalog\
  playbooks\          # content-patterns + agent-lessons
  tools\
  cursor-addons\      # rules-shared, project-root, skills, serena-shared, install
  INSTALL-TRANSFER.md
  README.md
```

Опционально (тяжело): `normalized_src\`, `archive_raw\`.

Подробно: `C:\1c-shared-patterns\INSTALL-TRANSFER.md`.

### 2.2. Junctions (рекомендуется)

```powershell
# из C:\Cursor видно как соседний проект
cmd /c mklink /J "C:\Cursor\1c-shared-patterns" "C:\1c-shared-patterns"

# если lean-ctx root = %USERPROFILE%
cmd /c mklink /J "%USERPROFILE%\1c-shared-patterns" "C:\1c-shared-patterns"
```

### 2.3. Установить agent pack во все проекты

```powershell
cd C:\1c-shared-patterns\cursor-addons\install
.\Sync-1cAgentPack.ps1 -WhatIf
.\Sync-1cAgentPack.ps1
.\Check-1cAgentDrift.ps1
```

Что раскладывает Sync:

| Из Hub | Куда |
|---|---|
| `rules-shared/hub-gate.mdc` | каждый `C:\Cursor\<proj>\.cursor\rules\` |
| `rules-shared/global-04-...` | то же |
| `project-root/AGENTS.md`, `memory.md`, `LLM-RULES.md`, `USER-RULES.md`, `.cursorrules` | корень каждого проекта |
| `serena-shared/*` | `.serena/memories/core_shared.md`, `pitfalls/shared/*` |
| skills consult / reuse / error-learning | `%USERPROFILE%\.cursor\skills\` |

**Правило:** shared править только в Hub → Sync. Копии в проектах с пометкой DO NOT EDIT — коммитить (A2), руками не править.

### 2.4. Что агент обязан делать (runtime)

Перед генерацией BSL/CFE/EPF/форм/Excel/query:

1. `C:\1c-shared-patterns\playbooks\agent-lessons\index.md` (max 2 файла)
2. CFE/EPF → skill `reuse-1c-shared-patterns` (`content_patterns_index.json`)
3. В ответе строка: `KB: …` | `KB: none` | `KB: skip-cosmetic`

Переносимые уроки после ошибок → `playbooks\agent-lessons\` + Sync, не только `memory-bank/reflection`.

---

## 3. Workspace проекта УТ

Скопируйте `C:\Cursor\UT25_85` (git / архив / robocopy).

```powershell
cd C:\Cursor\UT25_85
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

Затем снова (§2.3) `Sync-1cAgentPack.ps1`, если Hub ставили после клона проекта.

### 3.1. Вручную по проекту

| Шаг | Действие |
|---|---|
| `.dev.env` | из `.dev.env.example` при наличии |
| `infobasesettings.md` | локально, **не** в git |
| `.v8-project.json` | `webUrl` / login для Playwright |
| Extensions | `supercode.supercode-sh` и прочие по команде |
| MCP | Reload; `.cursor/MCP_SETUP.md`, `MCP_ROUTER.md` (`bsl-atlas`, code-index `UT25_85`) |
| Browser MCP | **не** нужны: UI через Playwright (`tests/web`), не puppeteer/screenshot |

---

## 4. Playwright / веб-автотесты 1С

Канон: skill **`1c-web-test`** + Playwright.  
Полная инструкция: **`tests/web/INSTALL.md`**.

### 4.1. Краткий чеклист на новом ПК

```powershell
# Node 18+
node -v
npm -v

# зависимости skill
cd "$env:USERPROFILE\.cursor\skills\1c-web-test\scripts"
npm install

# системный Chrome или Edge (предпочтительно; bundled chromium часто зависает)
Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# опционально
$env:PLAYWRIGHT_EXECUTABLE_PATH = "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

### 4.2. Предусловия УТ

1. ИБ опубликована: `http://localhost/UT25_85` (см. `infobasesettings.md`).
2. В корне есть `.v8-project.json` с `webUrl`, `login`, `password`.
3. Сценарии: `C:\Cursor\UT25_85\tests\web\`.

Проверка публикации:

```powershell
Invoke-WebRequest -Uri "http://localhost/UT25_85" -UseBasicParsing | Select-Object StatusCode
```

Smoke skill:

```powershell
cd "$env:USERPROFILE\.cursor\skills\1c-web-test\scripts"
node .\run.mjs start "http://localhost/UT25_85"
# … затем stop
```

Пример прогона проекта:

```powershell
cd C:\Cursor\UT25_85\tests\web
.\run-zapolnenie-vse-serii.ps1
```

### 4.3. Правила прогона (кратко)

- Только **headed** (`headless: false`).
- Перед стартом гасить старую web-test сессию / orphan Chrome.
- Для 1С ввод часто через clipboard paste, не обычный `type()`.
- Пароли не коммитить в публичные репо.

Источник skill: [Desko77/claude-code-skills-1c](https://github.com/Desko77/claude-code-skills-1c) → `skills/1c-web-test`  
(если Install-ESTI уже положил skill — достаточно `npm install` в `scripts`).

---

## 5. Контекст агента (актуально)

| Always-on / shared | Файл / место |
|---|---|
| Hub Gate | `.cursor/rules/hub-gate.mdc` (из Sync) |
| Error learning | `.cursor/rules/global-04-...` + skill `error-learning-1c` |
| Safe scope / MB / MCP | `global-00…03`, `24-always-mcp-tool-router`, `26-always-no-webfetch` |
| Продукт УТ | `01-ut-project-context.mdc` |
| Корень проекта | `AGENTS.md`, `memory.md`, `LLM-RULES.md`, `USER-RULES.md` (из Hub Sync) |
| Project skill | `.cursor/skills/ut-project` |
| Lessons | `C:\1c-shared-patterns\playbooks\agent-lessons\` |
| Patterns HOW | `C:\1c-shared-patterns\playbooks\content-patterns\` |
| Serena cache | `.serena/memories/pitfalls/shared/` |

Устаревшие имена вроде `00-cursor-agent-core`, `33-agent-error-learning-pipeline` как always-on SoT **не** использовать.

---

## 6. Проверка на новом ПК

1. `.\Check-1cAgentDrift.ps1` → PASS  
2. В чате: попросить новую CFE-логику → в ответе есть `KB:`  
3. `/doctor` при наличии  
4. Playwright: `tests/web` smoke или `run.mjs start`  
5. Dev-задача → caveman (по `USER-RULES.md`)

---

## 7. Обновление

### Глобальные CursorSettings

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Export-CursorSettings.ps1
powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
git add -A; git commit -m "chore: sync cursor settings"; git push
```

На втором ПК: `git pull` + `Install-ESTI-OnNewDevice.ps1` + project install.

### Hub / agent pack (чаще)

На основном ПК правите **только** `C:\1c-shared-patterns\...`, затем:

```powershell
cd C:\1c-shared-patterns\cursor-addons\install
.\Sync-1cAgentPack.ps1
.\Check-1cAgentDrift.ps1
```

На втором ПК: обновить каталог Hub (robocopy/git) → тот же Sync.

`/evolve` → правки `LLM-RULES.md` только в Hub `cursor-addons\project-root\` → Sync.

---

## 8. Связанные документы

| Документ | Тема |
|---|---|
| `C:\1c-shared-patterns\INSTALL-TRANSFER.md` | перенос Hub + F+ Lite |
| `C:\1c-shared-patterns\cursor-addons\README.md` | Sync pack |
| `tests/web/INSTALL.md` | Playwright подробно |
| `.cursor/MCP_SETUP.md`, `MCP_ROUTER.md` | MCP |
| `memory-bank/plan/plan-2026-07-23-fplus-lite-hub-gate.md` | план Hub Gate |
