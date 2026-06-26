# transcribe — альтернативные backend'ы

## faster-whisper (основной, см. SKILL.md)

Локально, бесплатно, русский язык. Рекомендуется.

## Gemini API (опционально, не используется по умолчанию)

Оригинал ai_rules_1c: Gemini 2.5 Flash + `--analyze-ui` для анализа экрана.

Требует `GEMINI_API_KEY` в `.env`. Не настраивать без явного запроса пользователя.

## whisper-local --serve

OpenAI-совместимый API на localhost. Python 3.11+.

## WhisperBridge CLI

SRT/VTT/JSON, diarization — тяжелее, опционально.
