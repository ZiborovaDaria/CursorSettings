---
name: transcribe
description: "Транскрибация аудио/видео локально (faster-whisper). Используй когда нужно извлечь речь из записи, встречи, видео. Требует однократный setup-once.ps1."
---

# transcribe — локальная транскрибация (faster-whisper)

Офлайн-транскрибация без API-ключа. Backend: **faster-whisper** (Python).

## Перед первым использованием

```powershell
& "$PSScriptRoot\scripts\setup-once.ps1"
```

Идемпотентно: повторный запуск пропускает установку если `.deps-ok` есть.

## Использование

```powershell
python "$skillDir\scripts\transcribe.py" "<FilePath>" [--output-dir DIR] [--with-summary] [--format md|txt|srt]
```

| Параметр | По умолчанию | Описание |
|---|---|---|
| `FilePath` | — | Путь к аудио/видео |
| `--output-dir` | `<папка_файла>/Transcript/` | Куда писать результат |
| `--with-summary` | off | Краткое резюме |
| `--format` | `md` | `md`, `txt`, `srt` |
| `--model` | `small` | Модель whisper (`tiny`/`base`/`small`/`medium`) |

## Форматы

- **Видео:** mp4, mkv, webm, avi, mov
- **Аудио:** mp3, wav, ogg, m4a, flac, aac

## Зависимости

- Python 3.9+
- ffmpeg в PATH (`winget install ffmpeg` если нет)
- `pip install -r requirements.txt` (через setup-once.ps1)

## Процедура для агента

1. Проверить/вызвать `setup-once.ps1` один раз за сессию если `.deps-ok` отсутствует.
2. Запустить `transcribe.py` с `PYTHONUNBUFFERED=1`.
3. Сообщить пути к выходным файлам.
4. Показать начало транскрипта или summary.

## Ограничения

- Первый запуск скачивает модель с HuggingFace (~150–500 MB для small/medium).
- Точность таймкодов ± несколько секунд.
- Gemini-вариант с `--analyze-ui` — только в `REFERENCES.md` (если появится ключ).
