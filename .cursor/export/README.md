# Bundled ~/.cursor + supercode for new device

| Папка | Источник | Куда при install |
|---|---|---|
| `global-rules/` | `%USERPROFILE%\.cursor\rules\` | `~/.cursor/rules/` |
| `global-skills/` | `%USERPROFILE%\.cursor\skills\` + `cavecrew` | `~/.cursor/skills/` |
| `global-scripts/` | `%USERPROFILE%\.cursor\scripts\` | `~/.cursor/scripts/` |
| `global-templates/` | `%USERPROFILE%\.cursor\templates\` | `~/.cursor/templates/` |
| `supercode/` | workspace `.supercode/` | `<repo>/.supercode/` |

**Не в bundle** (идут с Cursor или отдельно):
- `~/.cursor/skills-cursor/` — встроенные навыки Cursor (automate, canvas, …)
- `~/.cursor/commands/` — глобальных нет; команды в `.cursor/commands/` проекта

Обновить bundle на основном ПК:

```powershell
powershell -File .cursor\scripts\Export-CursorSettings.ps1
git add .cursor/export
git commit -m "chore: refresh cursor export bundle"
git push
```
