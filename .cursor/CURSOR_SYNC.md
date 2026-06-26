# Синхронизация Cursor между ПК — ЭСТИ

## Через Git (репозиторий `C:\Cursor\ESTI`) — **да**

| Путь | Содержимое |
|---|---|
| `.cursor/rules/*.mdc` | `00-esti-core`, situational rules |
| `.cursor/skills/esti-project/` | Навык проекта |
| `.cursor/MCP_*.md` | Роутер, матрица, QUICK_START, LITE_DEVICE |
| `.cursor/mcp.profile.power.json` | Шаблон Power |
| `.cursor/mcp.profile.lite.json` | Шаблон Lite |
| `.cursor/scripts/*.ps1` | Скрипты |
| `.cursor/infra/litecode-esti/` | docker-compose |

**Workflow:** `git pull` → `Install-ESTI-OnNewDevice.ps1` → Reload MCP.

Полная инструкция: **`INSTALL_OTHER_DEVICE.md`**.

## Локально на каждом ПК — **не в Git**

| Что | Почему |
|---|---|
| `.cursor/mcp.json` | Power vs Lite; merge из profile |
| `.cursor/mcp.local.json` | Секреты (пароль mcp-1c) |
| Docker volumes | Atlas Chroma, Memgraph — тяжёлые |
| `C:\bsl-atlas-indexes\ESTI` | Индекс Atlas (только Power) |
| `C:\bsl-litecode-data\ESTI` | Данные litecode (junction + отчёт) |
| `~/.cursor/mcp.json` | lean-ctx global |

Добавить в `.gitignore`: `mcp.local.json`.

## Cursor Settings Sync (аккаунт)

Синхронизирует UI, extensions, keybindings — **не** project rules из `.cursor/rules/`.

**Правила агента — только Git.**

## Одинаковые пути на обоих ПК

| Путь | Назначение |
|---|---|
| `C:\Cursor\ESTI` | Workspace |
| `C:\CursorMCP\` | MCP binaries |
| `C:\bsl-atlas-indexes\ESTI` | Atlas (Power) |
| `C:\bsl-litecode-data\ESTI` | Litecode data |

## Переключение device_profile

### На слабом ПК после pull

1. `00-esti-device-profile.mdc` → `device_profile: LITE`
2. Merge `mcp.profile.lite.json` → `mcp.json`
3. `Prepare-LitecodeData-ESTI.ps1` + docker fast
4. См. `MCP_LITE_DEVICE.md`

### На мощном ПК

1. `device_profile: POWER`
2. `mcp.json` = power profile (atlas + litecode)
3. Atlas: `Get-BslAtlasIndexStatus-ESTI.ps1`
4. Litecode: `docker compose up` в `infra/litecode-esti`

## Что коммитить при смене ПК

Коммитить **нужный** `device_profile` в `00-esti-device-profile.mdc` или держать локально без коммита (рекомендация: POWER в main, LITE — локальная ветка/не коммитить).
