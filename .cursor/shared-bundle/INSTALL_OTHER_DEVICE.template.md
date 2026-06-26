# Установка {{PROJECT_TITLE}} на новом устройстве

Проект: **{{PROJECT_ID}}** · путь: `{{PROJECT_PATH}}`

Глобальные настройки (один раз на ПК): [INSTALL_ALL_PROJECTS.md](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/INSTALL_ALL_PROJECTS.md).

**ЭСТИ:** полный чеклист MCP/litecode/memory — [INSTALL_OTHER_DEVICE.md](https://github.com/ZiborovaDaria/CursorSettings/blob/main/.cursor/INSTALL_OTHER_DEVICE.md).

---

## 1. Глобальные настройки (один раз)

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1   # при необходимости
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Ставит `~/.cursor/rules`, `~/.cursor/skills` (99), scripts, templates, skill deps.

## 2. Workspace проекта

Скопируйте каталог `{{PROJECT_PATH}}` на новый ПК (git / архив / robocopy).

## 3. Настройки проекта

```powershell
cd {{PROJECT_PATH}}
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

Создаёт при отсутствии:
- `memory-bank/` — Memory Bank (L0): `projectbrief.md`, `techContext.md`, `tasks.md`, …
- `memory.md` — карта слоёв L0–L3
- `handoffs/`, `.supercode/`, `.vscode/extensions.json`
- синхронизацию `global-*.mdc`

## 4. Вручную

| Шаг | Действие |
|---|---|
| User Rules | Текст из `USER-RULES.md` |
| `.dev.env` | Из `.dev.env.example` ([GitHub](https://github.com/ZiborovaDaria/CursorSettings)) |
| `infobasesettings.md` | Локально, не в git |
| `mcp.local.json` | Секреты ИБ — из example в репозитории |
| Extensions | `supercode.supercode-sh` |
| MCP | Reload; см. {{MCP_DOCS}} |
{{XML_ONLY_NOTE}}

## 5. MCP и индексы (per project)

| Компонент | Действие |
|---|---|
| `mcp.json` | Локально; шаблоны `mcp.profile.*.json` в репозитории настроек |
| **code-index** | alias repo = ID проекта; бинарник `C:\CursorMCP\` |
| **serena** | project MCP — Edit BSL |
| **lean-ctx** | global `~/.cursor/mcp.json` |
| **litecode / Atlas** | только если настроены для проекта (ESTI — обязательно) |

**Не для BSL:** `codegraph` — не использовать.

## 6. Память агента

| Слой | Где |
|---|---|
| L0 | `memory-bank/`, `memory.md` |
| L1 | lean-ctx `ctx_knowledge` |
| L2 | `.serena/memories/` |
| L3 | `.cursor/rules/*.mdc` |

Команды: `capture-error`, `reflect-lesson`, `/handoff`.

## 7. Контекст агента

| Always-on | Файл |
|---|---|
| Продукт | `{{CONTEXT_RULE}}` |
| Agent core | `00-cursor-agent-core.mdc` |
| Caveman | `32-agent-caveman.mdc` |
| Error pipeline | `33-agent-error-learning-pipeline.mdc` |

Навык: `{{SKILL}}` в `.cursor/skills/`.

## 8. Проверка

- `/doctor` в Cursor
- Dev-задача → caveman
- Review → связный русский

## 9. Обновление

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Restore-DistributionBundleFromGit.ps1
powershell -File .cursor\scripts\Export-CursorSettings.ps1
powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
git add -A; git commit -m "chore: sync cursor settings"; git push
powershell -File .cursor\scripts\Remove-LocalDistributionBundle.ps1   # опционально
```

На втором ПК: `git pull` → `Install-ESTI-OnNewDevice.ps1` → `Install-Project-OnNewDevice.ps1`.
