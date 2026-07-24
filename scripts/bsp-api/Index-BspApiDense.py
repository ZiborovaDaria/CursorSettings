#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build dense vector index for BSP API catalog using same model as bsl-atlas.

Model: qwen3-embedding:4b via Ollama (OLLAMA_BASE_URL, default http://127.0.0.1:11434)
Source: playbooks/bsp-api/catalog.jsonl → field `summary`
Output: playbooks/bsp-api/dense/{vectors.npy, meta.jsonl, INDEX.md}

Usage:
  python Index-BspApiDense.py
  python Index-BspApiDense.py --catalog ... --out-dir ... --batch-size 8
"""
from __future__ import annotations

import argparse
import json
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

import numpy as np

DEFAULT_MODEL = "qwen3-embedding:4b"
DEFAULT_OLLAMA = "http://127.0.0.1:11434"


def ollama_embed_batch(base_url: str, model: str, texts: list[str], timeout: int = 300) -> list[list[float]]:
    url = base_url.rstrip("/") + "/api/embed"
    body = json.dumps({"model": model, "input": texts}, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        data = json.load(resp)
    emb = data.get("embeddings")
    if not emb or len(emb) != len(texts):
        raise RuntimeError(f"Unexpected embed response: n={len(emb) if emb else 0} expected={len(texts)}")
    return emb


def embed_text(card: dict) -> str:
    summary = (card.get("summary") or "").strip()
    qn = card.get("qualified_name") or ""
    if summary:
        return summary
    return qn


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--catalog",
        default=r"C:\1c-shared-patterns\playbooks\bsp-api\catalog.jsonl",
    )
    ap.add_argument(
        "--out-dir",
        default=r"C:\1c-shared-patterns\playbooks\bsp-api\dense",
    )
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--ollama", default=DEFAULT_OLLAMA)
    ap.add_argument("--batch-size", type=int, default=8)
    ap.add_argument("--limit", type=int, default=0, help="0 = all cards")
    args = ap.parse_args()

    catalog = Path(args.catalog)
    out_dir = Path(args.out_dir)
    if not catalog.is_file():
        raise SystemExit(f"catalog not found: {catalog}")

    cards: list[dict] = []
    with catalog.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            cards.append(json.loads(line))
    if args.limit > 0:
        cards = cards[: args.limit]

    print(f"cards={len(cards)} model={args.model} ollama={args.ollama} batch={args.batch_size}")
    out_dir.mkdir(parents=True, exist_ok=True)

    vectors: list[np.ndarray] = []
    meta_rows: list[dict] = []
    t0 = time.time()
    bs = max(1, args.batch_size)

    for i in range(0, len(cards), bs):
        batch = cards[i : i + bs]
        texts = [embed_text(c) for c in batch]
        # retry once on transient errors
        for attempt in range(3):
            try:
                embs = ollama_embed_batch(args.ollama, args.model, texts)
                break
            except (urllib.error.URLError, TimeoutError, RuntimeError) as e:
                if attempt == 2:
                    raise
                print(f"  retry batch@{i}: {e}")
                time.sleep(1.5 * (attempt + 1))
        for c, e in zip(batch, embs):
            v = np.asarray(e, dtype=np.float32)
            # L2-normalize for cosine via dot
            n = float(np.linalg.norm(v))
            if n > 0:
                v = v / n
            vectors.append(v)
            meta_rows.append(
                {
                    "qualified_name": c.get("qualified_name"),
                    "module": c.get("module"),
                    "name": c.get("name"),
                    "kind": c.get("kind"),
                    "category": c.get("category"),
                    "summary": c.get("summary") or "",
                }
            )
        done = min(i + bs, len(cards))
        if done % 64 == 0 or done == len(cards):
            elapsed = time.time() - t0
            rate = done / elapsed if elapsed else 0
            print(f"  {done}/{len(cards)} ({rate:.1f} cards/s)")

    mat = np.vstack(vectors)
    np.save(out_dir / "vectors.npy", mat)

    meta_path = out_dir / "meta.jsonl"
    with meta_path.open("w", encoding="utf-8", newline="\n") as f:
        for row in meta_rows:
            f.write(json.dumps(row, ensure_ascii=False, separators=(",", ":")) + "\n")

    index_md = "\n".join(
        [
            "# BSP API dense index",
            "",
            f"- model: `{args.model}` (same as bsl-atlas OLLAMA_MODEL)",
            f"- ollama: `{args.ollama}`",
            f"- dim: {mat.shape[1]}",
            f"- cards: {mat.shape[0]}",
            f"- built_at: {datetime.now():%Y-%m-%d %H:%M:%S}",
            f"- source: `{catalog}`",
            "- embed_field: `summary` (fallback: qualified_name)",
            "- vectors: L2-normalized float32 → cosine = dot product",
            "",
            "## Search",
            "",
            "```powershell",
            f'python {Path(__file__).resolve().parent / "Search-BspApiDense.py"} "прочитать реквизит по ссылке"',
            "```",
            "",
        ]
    )
    (out_dir / "INDEX.md").write_text(index_md, encoding="utf-8")

    print(f"OK shape={mat.shape} -> {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
