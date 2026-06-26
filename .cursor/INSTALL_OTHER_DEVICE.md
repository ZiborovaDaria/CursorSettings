# Установка ЭСТИ на новом устройстве

Полный чеклист: правила, навыки, MCP. См. [RULES_INDEX.md](RULES_INDEX.md) · [INSTALL_ALL_PROJECTS.md](INSTALL_ALL_PROJECTS.md).

---

## 1. Глобально (один раз на ПК)

```powershell
git clone https://github.com/ZiborovaDaria/CursorSettings.git C:\Cursor\ESTI
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Install-ESTI-OnNewDevice.ps1 -Profile POWER
```

Ставит `~/.cursor/rules` (24), `~/.cursor/skills` (99), scripts, supercode export.

## 2. Проект ЭСТИ

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Install-Project-OnNewDevice.ps1
```

## 3. Вручную

| Шаг | Действие |
|---|---|
| User Rules | `USER-RULES.md` → Cursor Settings |
| `.dev.env` | из `.dev.env.example` |
| `infobasesettings.md` | локально |
| Extension | `supercode.supercode-sh` |
| MCP | Reload — [MCP_QUICK_START.md](MCP_QUICK_START.md) |

## 4. MCP (POWER)

```powershell
cd .cursor\infra\litecode-esti
docker compose up -d
powershell -File .cursor\scripts\Test-ESTI-MCPStack.ps1
```

Документация: [MCP_ROUTER_ESTI.md](MCP_ROUTER_ESTI.md) · [MCP_SETUP_ESTI.md](MCP_SETUP_ESTI.md) · [MCP_TOOLS_MATRIX.md](MCP_TOOLS_MATRIX.md).

**LITE:** [MCP_LITE_DEVICE.md](MCP_LITE_DEVICE.md) · `-Profile LITE` при install.

## 5. Профили MCP

| Файл | Назначение |
|---|---|
| `mcp.profile.power.json` | Шаблон POWER → копируется в `mcp.json` |
| `mcp.profile.lite.json` | Шаблон LITE |
| `mcp.local.json.example` | Секреты → `mcp.local.json` |

`mcp.json` не в git — создаётся install-скриптом.

## 6. Проверка

`/doctor` · dev-задача → caveman · review → связный русский.

## 7. Обновление

```powershell
cd C:\Cursor\ESTI
powershell -File .cursor\scripts\Export-CursorSettings.ps1
powershell -File .cursor\scripts\Spread-CursorSettings-ToProjects.ps1
git add -A; git commit -m "chore: sync cursor"; git push
```

На втором ПК: `git pull` + оба install-скрипта.
