---
name: md-to-docx
description: "Конвертация Markdown в Word (.docx). Локальный npm-проект, не npm install -g."
---

# md-to-docx — Markdown → DOCX

## Использование

```
/md-to-docx <input.md> [output.docx]
```

| Параметр | Обязательно | Описание |
|---|---|---|
| `input.md` | да | Исходный Markdown |
| `output.docx` | нет | Выход (по умолчанию рядом, `.md` → `.docx`) |

## Зависимости

- Node.js
- Локальный `package.json` в папке skill — **не** `npm install -g docx`

## Команда (PowerShell)

```powershell
$skillDir = "$env:USERPROFILE\.cursor\skills\md-to-docx"
& "$skillDir\scripts\ensure-deps.ps1"
$env:NODE_PATH = Join-Path $skillDir "node_modules"
node "$skillDir\scripts\md_to_docx.js" "<input.md>" "[output.docx]"
```

**Важно:** вызывать `ensure-deps.ps1` только если `node_modules\docx` отсутствует.

## Поддерживаемый Markdown

Заголовки, таблицы, списки, code blocks, ссылки, изображения, горизонтальные линии.
