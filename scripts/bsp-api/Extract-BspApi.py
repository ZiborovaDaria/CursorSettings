#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Extract BSP public API (#Область ПрограммныйИнтерфейс) into Hub catalog.

Usage:
  python Extract-BspApi.py --cf-root C:\\Cursor\\UT25_85
"""
from __future__ import annotations

import argparse
import json
import re
from datetime import datetime
from pathlib import Path

RE_VERSION = re.compile(r'Описание\.Версия\s*=\s*"([^"]+)"')
RE_COMMON_MODULE = re.compile(r"CommonModule\.([^<\s]+)")
RE_AREA = re.compile(r"^#Область\s+(\S+)")
RE_DECL = re.compile(
    r"^(Процедура|Функция)\s+([A-Za-zА-Яа-яЁё_][A-Za-zА-Яа-яЁё0-9_]*)\s*\("
)
RE_SUMMARY_STOP = re.compile(
    r"^(Параметры|Возвращаемое значение|Пример)\s*:", re.IGNORECASE
)


def read_text(path: Path) -> str:
    data = path.read_bytes()
    for enc in ("utf-8-sig", "utf-8", "cp1251"):
        try:
            return data.decode(enc)
        except UnicodeDecodeError:
            continue
    return data.decode("utf-8", errors="replace")


def bsp_version(cf_root: Path) -> str:
    p = cf_root / "CommonModules" / "ОбновлениеИнформационнойБазыБСП" / "Ext" / "Module.bsl"
    if not p.exists():
        return "unknown"
    m = RE_VERSION.search(read_text(p))
    return m.group(1) if m else "unknown"


def bsp_common_modules(cf_root: Path) -> list[str]:
    names: set[str] = set()
    top = cf_root / "Subsystems" / "СтандартныеПодсистемы.xml"
    sub = cf_root / "Subsystems" / "СтандартныеПодсистемы"
    files: list[Path] = []
    if top.exists():
        files.append(top)
    if sub.exists():
        files.extend(sub.rglob("*.xml"))
    for f in files:
        for m in RE_COMMON_MODULE.finditer(read_text(f)):
            names.add(m.group(1).strip())
    return sorted(names, key=lambda s: s.lower())


def summary_from_doc(full_doc: str) -> str:
    if not full_doc.strip():
        return ""
    buf: list[str] = []
    for line in full_doc.splitlines():
        t = line.strip()
        if RE_SUMMARY_STOP.match(t):
            break
        if t:
            buf.append(t)
    summary = " ".join(buf).strip()
    if len(summary) > 400:
        summary = summary[:397] + "..."
    return summary


def in_program_interface(stack: list[str]) -> bool:
    return any(r.startswith("ПрограммныйИнтерфейс") for r in stack)


def parse_module(module_name: str, module_path: Path, version: str) -> list[dict]:
    lines = read_text(module_path).splitlines()
    stack: list[str] = []
    pending: list[str] = []
    results: list[dict] = []
    category = "override" if module_name.endswith("Переопределяемый") else "interface"
    i = 0
    n = len(lines)
    while i < n:
        trim = lines[i].strip()
        m_area = RE_AREA.match(trim)
        if m_area:
            stack.append(m_area.group(1))
            pending.clear()
            i += 1
            continue
        if trim == "#КонецОбласти":
            if stack:
                stack.pop()
            pending.clear()
            i += 1
            continue
        if trim.startswith("//"):
            c = trim[2:]
            if c.startswith(" "):
                c = c[1:]
            pending.append(c)
            i += 1
            continue
        if trim == "":
            i += 1
            continue
        m_decl = RE_DECL.match(trim)
        if m_decl:
            kind_ru, name = m_decl.group(1), m_decl.group(2)
            decl = trim
            start_line = i + 1
            while True:
                if ")" in decl:
                    break
                i += 1
                if i >= n:
                    break
                decl = decl + " " + lines[i].strip()
            is_export = "Экспорт" in decl
            if in_program_interface(stack) and is_export:
                full_doc = "\n".join(pending).strip()
                summary = summary_from_doc(full_doc)
                if not summary and full_doc:
                    for ln in full_doc.splitlines():
                        if ln.strip():
                            summary = ln.strip()
                            break
                sig = decl if len(decl) <= 300 else decl[:297] + "..."
                results.append(
                    {
                        "qualified_name": f"{module_name}.{name}",
                        "module": module_name,
                        "name": name,
                        "kind": "function" if kind_ru == "Функция" else "procedure",
                        "category": category,
                        "signature": sig,
                        "summary": summary,
                        "full_doc": full_doc,
                        "bsp_version_extracted": version,
                        "source_hint": f"CommonModules/{module_name}/Ext/Module.bsl:{start_line}",
                    }
                )
            pending.clear()
            i += 1
            continue
        pending.clear()
        i += 1
    return results


def write_module_md(path: Path, module: str, cards: list[dict]) -> None:
    lines = [
        f"# {module}",
        "",
        f"category: {cards[0]['category']} | cards: {len(cards)}",
        "",
    ]
    for c in sorted(cards, key=lambda x: x["name"]):
        lines.append(f"## {c['name']}")
        lines.append("")
        lines.append(f"- qualified_name: `{c['qualified_name']}`")
        lines.append(f"- kind: {c['kind']}")
        lines.append(f"- summary: {c['summary']}")
        lines.append("")
        if c["full_doc"]:
            lines.append("````")
            lines.append(c["full_doc"])
            lines.append("````")
            lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--cf-root", default=r"C:\Cursor\UT25_85")
    ap.add_argument("--out-dir", default=r"C:\1c-shared-patterns\playbooks\bsp-api")
    args = ap.parse_args()
    cf_root = Path(args.cf_root)
    out_dir = Path(args.out_dir)
    if not cf_root.is_dir():
        raise SystemExit(f"CfRoot not found: {cf_root}")

    version = bsp_version(cf_root)
    modules = bsp_common_modules(cf_root)
    print(f"BSP version: {version}")
    print(f"CommonModules in СтандартныеПодсистемы: {len(modules)}")

    by_module = out_dir / "by-module"
    by_module.mkdir(parents=True, exist_ok=True)
    for old in by_module.glob("*.md"):
        old.unlink()

    all_cards: list[dict] = []
    modules_with_api = 0
    skipped = 0
    for mod in modules:
        bsl = cf_root / "CommonModules" / mod / "Ext" / "Module.bsl"
        if not bsl.exists():
            skipped += 1
            continue
        cards = parse_module(mod, bsl, version)
        if not cards:
            continue
        modules_with_api += 1
        all_cards.extend(cards)
        safe = re.sub(r'[\\/:*?"<>|]', "_", mod)
        write_module_md(by_module / f"{safe}.md", mod, cards)

    all_cards.sort(key=lambda c: c["qualified_name"])
    catalog = out_dir / "catalog.jsonl"
    with catalog.open("w", encoding="utf-8", newline="\n") as f:
        for c in all_cards:
            f.write(json.dumps(c, ensure_ascii=False, separators=(",", ":")) + "\n")

    sum_lines = [
        "# BSP API summaries",
        "",
        f"Extracted: {datetime.now():%Y-%m-%d %H:%M} | BSP {version} | source `{cf_root}`",
        "",
        "| qualified_name | summary |",
        "|---|---|",
    ]
    for c in all_cards:
        s = c["summary"].replace("|", "/").replace("\n", " ")
        sum_lines.append(f"| `{c['qualified_name']}` | {s} |")
    (out_dir / "summaries.md").write_text("\n".join(sum_lines) + "\n", encoding="utf-8")

    ver = "\n".join(
        [
            "# BSP API catalog version",
            "",
            f"- bsp_version_extracted: {version}",
            f"- extracted_at: {datetime.now():%Y-%m-%d %H:%M:%S}",
            f"- source_cf: {cf_root}",
            f"- common_modules_in_subsystem: {len(modules)}",
            f"- modules_with_api_cards: {modules_with_api}",
            f"- cards_total: {len(all_cards)}",
            f"- skipped_missing_bsl: {skipped}",
            "- scope: `#Область ПрограммныйИнтерфейс*` export only",
            "- creative: B (summary for FTS/vector; full_doc in catalog; locate by Module.Name)",
            "",
        ]
    )
    (out_dir / "VERSION.md").write_text(ver, encoding="utf-8")

    print(f"OK cards={len(all_cards)} modules_with_api={modules_with_api} -> {out_dir}")
    hit = next(
        (c for c in all_cards if c["qualified_name"] == "ОбщегоНазначения.ЗначениеРеквизитаОбъекта"),
        None,
    )
    if not hit:
        print("SMOKE FAIL: ОбщегоНазначения.ЗначениеРеквизитаОбъекта not found")
        return 2
    print(f"SMOKE OK: {hit['qualified_name']}")
    print(f"  summary: {hit['summary'][:120]}...")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
