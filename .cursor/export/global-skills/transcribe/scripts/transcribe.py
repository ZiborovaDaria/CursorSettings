#!/usr/bin/env python3
"""Local transcription via faster-whisper. Extracts audio with ffmpeg if needed."""

import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path

AUDIO_EXT = {".mp3", ".wav", ".ogg", ".m4a", ".flac", ".aac", ".wma"}
VIDEO_EXT = {".mp4", ".mkv", ".webm", ".avi", ".mov"}


def extract_audio(src: Path, dst: Path) -> None:
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(src), "-vn", "-acodec", "pcm_s16le", "-ar", "16000", "-ac", "1", str(dst)],
        check=True,
        capture_output=True,
    )


def format_ts(seconds: float) -> str:
    m, s = divmod(int(seconds), 60)
    h, m = divmod(m, 60)
    if h:
        return f"{h:02d}:{m:02d}:{s:02d}"
    return f"{m:02d}:{s:02d}"


def main() -> int:
    parser = argparse.ArgumentParser(description="Transcribe audio/video with faster-whisper")
    parser.add_argument("input", help="Path to audio or video file")
    parser.add_argument("--output-dir", help="Output directory")
    parser.add_argument("--with-summary", action="store_true")
    parser.add_argument("--format", choices=["md", "txt", "srt"], default="md")
    parser.add_argument("--model", default="small")
    parser.add_argument("--language", default="ru")
    args = parser.parse_args()

    src = Path(args.input).resolve()
    if not src.exists():
        print(f"Error: file not found: {src}", file=sys.stderr)
        return 1

    out_dir = Path(args.output_dir) if args.output_dir else src.parent / "Transcript" / src.stem
    out_dir.mkdir(parents=True, exist_ok=True)

    work_file = src
    tmp_wav = None
    if src.suffix.lower() in VIDEO_EXT or src.suffix.lower() not in AUDIO_EXT:
        tmp_wav = Path(tempfile.mkstemp(suffix=".wav")[1])
        print(f"Extracting audio via ffmpeg...")
        extract_audio(src, tmp_wav)
        work_file = tmp_wav

    try:
        from faster_whisper import WhisperModel

        print(f"Loading model '{args.model}' (first run may download)...")
        model = WhisperModel(args.model, device="cpu", compute_type="int8")
        segments, info = model.transcribe(str(work_file), language=args.language, beam_size=5)

        lines_md = [f"# Transcript: {src.name}\n", f"Language: {info.language} (p={info.language_probability:.2f})\n\n"]
        lines_txt = []
        lines_srt = []
        full_text = []

        for i, seg in enumerate(segments, 1):
            ts = format_ts(seg.start)
            line = seg.text.strip()
            full_text.append(line)
            lines_md.append(f"[{ts}] {line}\n")
            lines_txt.append(f"[{ts}] {line}\n")
            end = format_ts(seg.end).replace(":", ",")
            start = format_ts(seg.start).replace(":", ",")
            lines_srt.append(f"{i}\n{start} --> {end}\n{line}\n")

        ext = args.format
        out_transcript = out_dir / f"{src.stem} - transcript.{ext}"
        content = {"md": "".join(lines_md), "txt": "".join(lines_txt), "srt": "\n".join(lines_srt)}[ext]
        out_transcript.write_text(content, encoding="utf-8")
        print(f"Created: {out_transcript}")

        if args.with_summary:
            summary_path = out_dir / f"{src.stem} - summary.md"
            text = " ".join(full_text)
            preview = text[:2000] + ("..." if len(text) > 2000 else "")
            summary_path.write_text(f"# Summary: {src.name}\n\n{preview}\n", encoding="utf-8")
            print(f"Created: {summary_path}")

        return 0
    finally:
        if tmp_wav and tmp_wav.exists():
            tmp_wav.unlink(missing_ok=True)


if __name__ == "__main__":
    sys.exit(main())
