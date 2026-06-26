# Установка {{PROJECT_TITLE}} на новом устройстве

Проект: **{{PROJECT_ID}}** · путь: `{{PROJECT_PATH}}`

Глобальные настройки (один раз на ПК): см. [INSTALL_ALL_PROJECTS.md](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/INSTALL_ALL_PROJECTS.md).

---

## 1. Глобальные настройки (один раз)

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Это ставит `~/.cursor/rules`, `~/.cursor/skills` (99 навыков), scripts, templates.

## 2. Workspace проекта

Скопируйте каталог `{{PROJECT_PATH}}` на новый ПК (git / архив / robocopy).

## 3. Настройки проекта

```powershell
cd {{PROJECT_PATH}}
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

## 4. Вручную

| Шаг | Действие |
|---|---|
| User Rules | Текст из `USER-RULES.md` |
| `.dev.env` | Из `.dev.env.example` если есть |
| `infobasesettings.md` | Локально, не в git |
| Extensions | `supercode.supercode-sh` |
| MCP | Reload; см. {{MCP_DOCS}} |
{{XML_ONLY_NOTE}}

## 5. Контекст агента

| Always-on | Файл |
|---|---|
| Продукт | `{{CONTEXT_RULE}}` |
| Agent core | `00-cursor-agent-core.mdc` |
| Caveman | `32-agent-caveman.mdc` |
| Error pipeline | `33-agent-error-learning-pipeline.mdc` |

Навык: `{{SKILL}}` в `.cursor/skills/`.

## 6. Проверка

- `/doctor` в Cursor
- Dev-задача → короткий caveman-ответ
- Review → связный русский

## 7. Обновление

На основном ПК после правок глобальных настроек:

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Export-CursorSettings.ps1
powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
git add -A; git commit -m "chore: sync cursor settings"; git push
```

На втором ПК: `git pull` в CursorSettings + `Install-ESTI-OnNewDevice.ps1` + `Install-Project-OnNewDevice.ps1` в каждом проекте.
