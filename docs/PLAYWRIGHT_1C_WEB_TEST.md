# Playwright / 1c-web-test — установка (shared)

Канон для всех проектов `C:\Cursor`. Источник skill: [Desko77/claude-code-skills-1c](https://github.com/Desko77/claude-code-skills-1c).

Ниже — рабочая инструкция (пример путей УТ `UT25_85`; в другом проекте замените `webUrl` / каталог `tests/web`).

См. также: [.cursor/INSTALL_ALL_PROJECTS.md](../.cursor/INSTALL_ALL_PROJECTS.md) §1c · [HUB_FPLUS_LITE.md](HUB_FPLUS_LITE.md).

---
Общий стек для проектов в `C:\Cursor`: skill один на машину, сценарии — в `tests/web/` каждого workspace.
Канон UI/web e2e: skill `1c-web-test` + Playwright. MCP `puppeteer-real-browser` / `screenshot` в проекте **не подключены** (убраны из `mcp.json`).

## Что ставим

| Компонент | Зачем | Куда |
|---|---|---|
| Node.js 18+ | runtime | система |
| npm-пакет `playwright` | браузерный движок | `~/.cursor/skills/1c-web-test/scripts` |
| skill `1c-web-test` | DSL под веб-клиент 1С (`navigateLink`, `clickElement`, `readTable`…) | `C:\Users\Admin\.cursor\skills\1c-web-test` |
| Chrome или Edge | реальный браузер для headed-режима | система |
| сценарии проекта | конкретные smoke/e2e | `tests/web/` |

Источник skill: [Desko77/claude-code-skills-1c](https://github.com/Desko77/claude-code-skills-1c) → `skills/1c-web-test`.

## 1. Предусловия проекта

1. База опубликована в веб-клиенте.
2. В корне проекта есть `.v8-project.json` с `webUrl`, `login`, `password`.
3. Пример для UT:

```json
{
  "databases": [
    {
      "id": "ut",
      "webUrl": "http://localhost/UT25_85",
      "login": "Admin",
      "password": "1"
    }
  ]
}
```

Проверка:

```powershell
Invoke-WebRequest -Uri "http://localhost/UT25_85" -UseBasicParsing | Select-Object StatusCode
```

## 2. Установка движка

### 2.1. Проверить Node / npm

```powershell
node -v
npm -v
```

Нужны Node.js 18+ и npm.

### 2.2. Установить зависимости skill

```powershell
cd "$env:USERPROFILE\.cursor\skills\1c-web-test\scripts"
npm install
```

Это ставит пакет `playwright` (см. `package.json` skill).

### 2.3. Браузер: предпочтительно системный Chrome/Edge

В этом проекте `npx playwright install chromium` зависал на скачивании bundled Chromium.
Рабочий путь: использовать уже установленный Chrome/Edge.

Проверка наличия:

```powershell
Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
```

Опционально явно указать бинарник:

```powershell
$env:PLAYWRIGHT_EXECUTABLE_PATH = "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

В runner `browser.mjs` skill добавлен fallback на системный Chrome/Edge, если bundled Chromium отсутствует.

### 2.4. (Опционально) bundled Chromium

Если сеть стабильна:

```powershell
cd "$env:USERPROFILE\.cursor\skills\1c-web-test\scripts"
npx playwright install chromium
```

Для 1С это не обязательно: headed-режим на системном Chrome обычно надёжнее.

## 3. Структура в проекте 1С

```text
tests/web/
  INSTALL.md                 ← эта инструкция
  TEMPLATE.exec.js           ← шаблон сценария
  run-template.ps1           ← шаблон запуска
  zapolnenie-vse-serii.exec.js
  run-zapolnenie-vse-serii.ps1
```

Каталог `tests/web` лежит в workspace проекта (например `C:\Cursor\UT25_85\tests\web`).

## 4. Быстрая проверка стека

Интерактивно:

```powershell
cd "$env:USERPROFILE\.cursor\skills\1c-web-test\scripts"
node .\run.mjs start "http://localhost/UT25_85"
```

Дальше из другого терминала:

```powershell
cd "$env:USERPROFILE\.cursor\skills\1c-web-test\scripts"
@'
const page = getPage();
console.log(page.url());
console.log((await page.locator("body").innerText()).slice(0, 500));
'@ | node .\run.mjs exec - --no-record

node .\run.mjs stop
```

Автономный прогон:

```powershell
cd C:\Cursor\UT25_85\tests\web
.\run-zapolnenie-vse-serii.ps1
```

## 5. Обязательные правила прогона для 1С

1. Перед стартом закрывать старую web-test сессию и orphan Chrome.
2. После закрытия лишних сеансов веб-клиент часто виснет на splash — нужен soft reload + hard restart.
3. Только headed-режим (`headless: false`).
4. Для ввода в поля 1С skill использует clipboard paste, не обычный `type()`.
5. Перед повторным прогоном гасить лицензионные/зависшие сеансы веб-клиента.
6. Не коммитить пароли в публичные репозитории; брать их из `.v8-project.json` / `.dev.env`.

## 6. Что уже настроено (все проекты `C:\Cursor`)

- skill (общий): `C:\Users\Admin\.cursor\skills\1c-web-test`
- `npm install` выполнен в `...\scripts` (playwright)
- fallback на системный Chrome/Edge в `browser.mjs`
- в каждом 1С-проекте: `tests/web/` + `.v8-project.json` с `webUrl`
- проекты без ИБ (`Obshep`, `UNF12_261`, `UPO`): в `.v8-project.json` стоит `ibAvailable: false` — прогон заблокирован до появления публикации
- рабочий пример только в UT25_85: `tests/web/zapolnenie-vse-serii.*`
- launcher сам:
  - закрывает предыдущую сессию;
  - убивает orphan Playwright Chrome;
  - делает до 3 hard-restart попыток;
  - внутри сценария — до 3 soft-reload при зависании boot.

## 7. Типовые сбои

| Симптом | Что делать |
|---|---|
| `Executable doesn't exist ... chromium-...` | поставить системный Chrome/Edge или `npx playwright install chromium` |
| `Не найдена лицензия` / список чужих сеансов | закрыть старые сеансы, в сценарии нажать `Выполнить запуск` |
| зависание после splash | soft reload в сценарии; если не помогло — hard restart launcher |
| кнопка расширения не найдена | проверить, что CFE загружено в ИБ и форма реально открыта |
| `page.url is not a function` | вызывать `getPage()`, это sync-функция skill |

## 8. Как сделать новый прогон из шаблона

```powershell
cd C:\Cursor\UT25_85\tests\web
Copy-Item TEMPLATE.exec.js my-feature.exec.js
Copy-Item run-template.ps1 run-my-feature.ps1
```

В `my-feature.exec.js` поменять константы (`OBJECT_LINK`, `LIST_ROW_TEXT`, `TARGET_TAB`, `TARGET_BUTTON`…).
В `run-my-feature.ps1` указать имя своего `.exec.js`.

Запуск:

```powershell
.\run-my-feature.ps1
```

## 9. Связанные файлы

- skill API: `C:\Users\Admin\.cursor\skills\1c-web-test\SKILL.md`
- URL/логин: `.v8-project.json`
- MCP router (без browser MCP): `.cursor/MCP_SETUP.md`, `MCP_ROUTER.md`

