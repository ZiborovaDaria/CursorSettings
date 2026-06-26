# /doctor — проверка стека ESTI

## Действия

1. Запустить `.cursor/scripts/Test-ESTI-MCPStack.ps1` (если есть) или проверить MCP вручную:
   - `bsl-atlas-esti` (POWER) / `litecode` (LITE)
   - `serena`, `lean-ctx`, `1c-naparnik`, `v8std`
2. Проверить `device_profile` в `00-esti-device-profile.mdc` vs `.cursor/mcp.json`
3. **Опционально** — deps навыков (идемпотентно):

```powershell
powershell -File .cursor/scripts/Install-ESTI-SkillDeps.ps1
```

4. Краткий отчёт: что OK, что сломано, что нужно пользователю.
