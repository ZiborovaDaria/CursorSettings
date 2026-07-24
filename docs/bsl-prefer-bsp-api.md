---
id: bsl-prefer-bsp-api
title: Prefer BSP public API over inventing utils
scope: global
surfaces: [bsl, process]
severity: high
kind: anti-pattern
---

## Trigger
- пишет «свою» утилиту (реквизиты, строки, массивы, фон, файлы, печать, сообщения пользователю…) без поиска в БСП
- копирует куски логики вместо вызова `ОбщегоНазначения.*` / `ДлительныеОперации.*` и т.п.

## Why bad
- Дублирование уже стабильного ПИ БСП; регрессии при обновлении; расхождение с типовым поведением.

## Required behavior
1. Перед новой общей функцией/процедурой — **dense-поиск БСП**:
   ```powershell
   python C:\1c-shared-patterns\scripts\Search-BspApiDense.py "<задача>" --top 5 --category interface
   ```
2. Skill `1c-ssl-patterns`; каталог `playbooks/bsp-api/`.
3. При hit — взять `qualified_name`, locate тело в **текущей** КФ, вызвать API; не писать клон.
4. Свой код — только если API нет / не подходит (кратко почему).

## Related
- skill: `1c-ssl-patterns`
- hub: `playbooks/bsp-api/README.md`
