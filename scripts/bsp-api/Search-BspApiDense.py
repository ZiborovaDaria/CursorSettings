#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Dense search over BSP API index (qwen3-embedding:4b / Ollama).

Usage:
  python Search-BspApiDense.py "прочитать реквизит по ссылке"
  python Search-BspApiDense.py "фон с прогрессом" --top 8 --json
"""
from __future__ import annotations

import argparse
import json
import urllib.request
from pathlib import Path

import numpy as np

DEFAULT_MODEL = "qwen3-embedding:4b"
DEFAULT_OLLAMA = "http://127.0.0.1:11434"
DEFAULT_INDEX = r"C:\1c-shared-patterns\playbooks\bsp-api\dense"
DEFAULT_CATALOG = r"C:\1c-shared-patterns\playbooks\bsp-api\catalog.jsonl"


def ollama_embed(base_url: str, model: str, text: str) -> np.ndarray:
    url = base_url.rstrip("/") + "/api/embed"
    body = json.dumps({"model": model, "input": text}, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        data = json.load(resp)
    emb = data.get("embeddings")
    if not emb:
        raise RuntimeError("empty embeddings")
    v = np.asarray(emb[0], dtype=np.float32)
    n = float(np.linalg.norm(v))
    if n > 0:
        v = v / n
    return v


def load_full_docs(catalog: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not catalog.is_file():
        return out
    with catalog.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            c = json.loads(line)
            qn = c.get("qualified_name")
            if qn:
                out[qn] = c.get("full_doc") or ""
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description="Dense search BSP API")
    ap.add_argument("query", help="Natural language query (Russian OK)")
    ap.add_argument("--index-dir", default=DEFAULT_INDEX)
    ap.add_argument("--catalog", default=DEFAULT_CATALOG)
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--ollama", default=DEFAULT_OLLAMA)
    ap.add_argument("--top", type=int, default=5)
    ap.add_argument("--json", action="store_true", help="JSON output")
    ap.add_argument("--with-doc", action="store_true", help="Include full_doc from catalog")
    ap.add_argument("--category", default="", help="Filter: interface|override")
    args = ap.parse_args()

    index_dir = Path(args.index_dir)
    vectors_path = index_dir / "vectors.npy"
    meta_path = index_dir / "meta.jsonl"
    if not vectors_path.is_file() or not meta_path.is_file():
        raise SystemExit(
            f"Index not found in {index_dir}. Run: python Index-BspApiDense.py"
        )

    mat = np.load(vectors_path)
    meta: list[dict] = []
    with meta_path.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                meta.append(json.loads(line))
    if mat.shape[0] != len(meta):
        raise SystemExit(f"vectors/meta mismatch: {mat.shape[0]} vs {len(meta)}")

    q = ollama_embed(args.ollama, args.model, args.query)
    scores = mat @ q  # cosine, vectors are normalized

    order = np.argsort(-scores)
    results = []
    full_docs = load_full_docs(Path(args.catalog)) if args.with_doc else {}

    for idx in order:
        m = meta[int(idx)]
        if args.category and m.get("category") != args.category:
            continue
        item = {
            "score": float(scores[int(idx)]),
            "qualified_name": m.get("qualified_name"),
            "module": m.get("module"),
            "name": m.get("name"),
            "kind": m.get("kind"),
            "category": m.get("category"),
            "summary": m.get("summary"),
        }
        if args.with_doc:
            item["full_doc"] = full_docs.get(item["qualified_name"] or "", "")
        results.append(item)
        if len(results) >= args.top:
            break

    if args.json:
        print(json.dumps({"query": args.query, "results": results}, ensure_ascii=False, indent=2))
    else:
        print(f"query: {args.query}")
        print(f"model: {args.model} | hits: {len(results)}")
        print()
        for i, r in enumerate(results, 1):
            print(f"{i}. {r['score']:.4f}  {r['qualified_name']}")
            sm = (r.get("summary") or "")[:180]
            print(f"   {sm}")
            print()
    return 0


if __name__ == "__main__":
    import sys
    if hasattr(sys.stdout, "reconfigure"):
        try:
            sys.stdout.reconfigure(encoding="utf-8")
        except Exception:
            pass
    raise SystemExit(main())
