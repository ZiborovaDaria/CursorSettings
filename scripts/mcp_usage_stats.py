# -*- coding: utf-8 -*-
"""MCP vs Grep usage stats from Cursor agent-transcripts.

Features:
- MCP / Grep / Read / Shell counts
- dual-channel turns (MCP search + Grep in same assistant turn)
- session mix (mcp-only / grep-only / both)
- tool_result probe (success-rate if present in jsonl)
- enriched KPI JSON for canvas / weekly review

Usage:
  python scripts/mcp_usage_stats.py
  python scripts/mcp_usage_stats.py --since 2026-07-20 --out-dir ...
"""
from __future__ import annotations

import argparse
import json
import re
from collections import defaultdict
from datetime import datetime
from pathlib import Path

PROJECTS_ROOT = Path.home() / ".cursor" / "projects"
DEFAULT_PROJECTS = [
    "c-Cursor-BP",
    "c-Cursor-ESTI",
    "c-Cursor-UT25-85",
    "c-Cursor-UNF12-261",
    "c-Cursor-UT22-92",
    "c-Cursor-UPO",
    "c-Cursor-KA",
    "c-Cursor-Obshep",
]

MCP_SEARCH_TOOLS = re.compile(
    r"^(ctx_search|codesearch|code_grep|grep_code|grep_body|grep_text|"
    r"search_code_filtered|search_for_pattern|search_text|search_function|"
    r"find_symbol|metadatasearch|search_metadata)$"
)


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--since", default="2026-07-02", help="YYYY-MM-DD")
    p.add_argument(
        "--out-dir",
        default=str(PROJECTS_ROOT / "c-Cursor-BP" / "canvases"),
    )
    p.add_argument("--tag", default="", help="suffix for output files")
    return p.parse_args()


def collect_files(since: datetime) -> list[Path]:
    files: list[Path] = []
    for name in DEFAULT_PROJECTS:
        root = PROJECTS_ROOT / name / "agent-transcripts"
        if not root.is_dir():
            continue
        for f in root.rglob("*.jsonl"):
            mtime = datetime.fromtimestamp(f.stat().st_mtime)
            if mtime >= since:
                files.append(f)
    return files


def project_of(path: Path) -> str:
    parts = path.parts
    try:
        i = parts.index("projects")
        return parts[i + 1]
    except (ValueError, IndexError):
        return "unknown"


def analyze(files: list[Path], since: datetime) -> dict:
    by_server: dict[str, int] = defaultdict(int)
    by_tool: dict[str, int] = defaultdict(int)
    by_native: dict[str, int] = defaultdict(int)
    by_day: dict[str, dict] = {}
    by_project: dict[str, dict] = {}

    total_turns = 0
    user_queries = 0
    dual_turns = 0
    sessions_both = 0
    sessions_mcp_only = 0
    sessions_grep_only = 0
    sessions_neither = 0

    tool_result_lines = 0
    tool_use_lines = 0
    tool_result_error_hints = 0

    mcp_search_exact = 0
    ctx_read = 0
    ctx_shell = 0
    ctx_tree = 0
    ctx_url_read = 0
    webfetch_calls = 0
    discovery = 0
    sessions_webfetch = 0

    for path in files:
        proj = project_of(path)
        day = datetime.fromtimestamp(path.stat().st_mtime).strftime("%Y-%m-%d")
        if day not in by_day:
            by_day[day] = defaultdict(int)
        if proj not in by_project:
            by_project[proj] = {
                "mcp": 0,
                "grep": 0,
                "read": 0,
                "shell": 0,
                "sessions": 0,
                "dual_turns": 0,
                "webfetch": 0,
                "ctx_url_read": 0,
            }
        by_project[proj]["sessions"] += 1

        sess_mcp_search = False
        sess_grep = False
        sess_webfetch = False

        with path.open("r", encoding="utf-8", errors="replace") as fh:
            for line in fh:
                if "tool_result" in line:
                    tool_result_lines += 1
                    if re.search(r"(?i)error|failed|blocked|escapes project root", line):
                        tool_result_error_hints += 1
                if '"tool_use"' not in line and '"role":"user"' not in line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue

                if obj.get("role") == "user":
                    user_queries += 1
                    continue
                if obj.get("role") != "assistant":
                    continue

                content = obj.get("message", {}).get("content")
                if not content:
                    continue
                total_turns += 1
                turn_mcp_search = False
                turn_grep = False

                for part in content if isinstance(content, list) else [content]:
                    if not isinstance(part, dict) or part.get("type") != "tool_use":
                        continue
                    tool_use_lines += 1
                    name = part.get("name") or ""
                    inp = part.get("input") or {}

                    if name in ("CallMcpTool", "FetchMcpResource"):
                        server = inp.get("server") or "unknown"
                        tool = (
                            "FetchMcpResource"
                            if name == "FetchMcpResource"
                            else (inp.get("toolName") or "unknown")
                        )
                        by_server[server] += 1
                        by_tool[f"{server}::{tool}"] += 1
                        by_day[day]["mcp"] += 1
                        by_project[proj]["mcp"] += 1
                        if MCP_SEARCH_TOOLS.match(tool):
                            mcp_search_exact += 1
                            turn_mcp_search = True
                            sess_mcp_search = True
                        if tool == "ctx_read":
                            ctx_read += 1
                        elif tool == "ctx_shell":
                            ctx_shell += 1
                        elif tool == "ctx_tree":
                            ctx_tree += 1
                        elif tool == "ctx_url_read":
                            ctx_url_read += 1
                            by_day[day]["ctx_url_read"] += 1
                            by_project[proj]["ctx_url_read"] += 1
                    elif name == "GetMcpTools":
                        discovery += 1
                        by_day[day]["mcp"] += 1
                        by_project[proj]["mcp"] += 1
                        by_tool["_discovery_::GetMcpTools"] += 1
                    elif name == "WebFetch":
                        webfetch_calls += 1
                        sess_webfetch = True
                        by_native["WebFetch"] += 1
                        by_day[day]["webfetch"] += 1
                        by_project[proj]["webfetch"] += 1
                    elif name == "Grep":
                        by_native["Grep"] += 1
                        by_day[day]["grep"] += 1
                        by_project[proj]["grep"] += 1
                        turn_grep = True
                        sess_grep = True
                    elif name == "Read":
                        by_native["Read"] += 1
                        by_day[day]["read"] += 1
                        by_project[proj]["read"] += 1
                    elif name == "Shell":
                        by_native["Shell"] += 1
                        by_day[day]["shell"] += 1
                        by_project[proj]["shell"] += 1
                        cmd = str(inp.get("command") or "")
                        if re.search(r"(?i)\b(rg|grep)\b|Select-String|findstr", cmd):
                            by_native["ShellGrepLike"] += 1
                            by_day[day]["grep"] += 1
                            by_project[proj]["grep"] += 1
                            turn_grep = True
                            sess_grep = True
                    elif name == "Glob":
                        by_native["Glob"] += 1
                    else:
                        by_native[name] += 1

                if turn_mcp_search and turn_grep:
                    dual_turns += 1
                    by_project[proj]["dual_turns"] += 1

        if sess_webfetch:
            sessions_webfetch += 1
        if sess_mcp_search and sess_grep:
            sessions_both += 1
        elif sess_mcp_search:
            sessions_mcp_only += 1
        elif sess_grep:
            sessions_grep_only += 1
        else:
            sessions_neither += 1

    grep_total = by_native.get("Grep", 0) + by_native.get("ShellGrepLike", 0)
    mcp_calls = sum(by_server.values()) + discovery
    search_share = (
        round(100 * mcp_search_exact / (mcp_search_exact + grep_total), 1)
        if (mcp_search_exact + grep_total)
        else 0
    )
    read_share = (
        round(100 * ctx_read / (ctx_read + by_native.get("Read", 0)), 1)
        if (ctx_read + by_native.get("Read", 0))
        else 0
    )

    tool_result_available = tool_result_lines > 0
    success_rate = None
    if tool_result_available and tool_result_lines:
        # heuristic only — real is_error flag often absent
        success_rate = round(
            100 * (1 - tool_result_error_hints / max(tool_result_lines, 1)), 1
        )

    return {
        "period": {
            "from": since.strftime("%Y-%m-%d"),
            "to": datetime.now().strftime("%Y-%m-%d"),
            "generated": datetime.now().isoformat(timespec="seconds"),
        },
        "summary": {
            "transcripts": len(files),
            "user_queries": user_queries,
            "assistant_turns": total_turns,
            "mcp_calls": mcp_calls,
            "native_grep": by_native.get("Grep", 0),
            "shell_grep_like": by_native.get("ShellGrepLike", 0),
            "grep_total": grep_total,
            "mcp_search_exact": mcp_search_exact,
            "search_mcp_share_pct": search_share,
            "native_read": by_native.get("Read", 0),
            "ctx_read": ctx_read,
            "read_mcp_share_pct": read_share,
            "native_shell": by_native.get("Shell", 0),
            "ctx_shell": ctx_shell,
            "native_glob": by_native.get("Glob", 0),
            "ctx_tree": ctx_tree,
            "ctx_url_read": ctx_url_read,
            "webfetch_calls": webfetch_calls,
            "webfetch_sessions": sessions_webfetch,
            "discovery_getmcp": discovery,
            "dual_search_turns": dual_turns,
            "sessions_both_mcp_search_and_grep": sessions_both,
            "sessions_mcp_only": sessions_mcp_only,
            "sessions_grep_only": sessions_grep_only,
            "sessions_neither": sessions_neither,
            "kpi_targets": {
                "search_mcp_share_pct": 70,
                "read_mcp_share_pct": 40,
                "sessions_both_pct_max": 30,
                "webfetch_calls_target_max": 0,
            },
        },
        "dual_channel": {
            "turns_both_mcp_and_grep_search": dual_turns,
            "sessions_both": sessions_both,
            "sessions_total": len(files),
            "sessions_both_pct": round(100 * sessions_both / max(len(files), 1), 1),
            "note": "Early-warning metric: spike = rules regressing to dual-channel",
        },
        "webfetch": {
            "webfetch_calls": webfetch_calls,
            "webfetch_sessions": sessions_webfetch,
            "ctx_url_read_calls": ctx_url_read,
            "sessions_webfetch_pct": round(
                100 * sessions_webfetch / max(len(files), 1), 1
            ),
            "note": "No WebFetch policy: prefer ctx_url_read / clone / uploads; target webfetch_calls→0 on research sessions",
        },
        "tool_result_probe": {
            "tool_use_events": tool_use_lines,
            "tool_result_lines_mention": tool_result_lines,
            "available_in_jsonl": tool_result_available,
            "error_hint_lines": tool_result_error_hints,
            "heuristic_success_rate_pct": success_rate,
            "note": "If available=false, success-rate cannot be measured from transcripts",
        },
        "by_server": dict(by_server),
        "by_tool_top": [
            {"k": k, "v": v}
            for k, v in sorted(by_tool.items(), key=lambda x: -x[1])[:40]
        ],
        "by_native": dict(by_native),
        "by_day": {d: dict(v) for d, v in sorted(by_day.items())},
        "by_project": by_project,
    }


def main():
    args = parse_args()
    since = datetime.strptime(args.since, "%Y-%m-%d")
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    tag = f"-{args.tag}" if args.tag else ""

    files = collect_files(since)
    print(f"Files: {len(files)} since {args.since}")
    result = analyze(files, since)

    raw_path = out_dir / f"mcp-stats-raw{tag}.json"
    enriched_path = out_dir / f"mcp-stats-enriched{tag}.json"
    raw_path.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")

    s = result["summary"]
    dual = result["dual_channel"]
    wf = result["webfetch"]
    enriched = {
        "period": result["period"],
        "search_mcp_share_pct": s["search_mcp_share_pct"],
        "read_mcp_share_pct": s["read_mcp_share_pct"],
        "mcp_search_exact": s["mcp_search_exact"],
        "grep_total": s["grep_total"],
        "dual_search_turns": dual["turns_both_mcp_and_grep_search"],
        "sessions_both_pct": dual["sessions_both_pct"],
        "sessions_both": dual["sessions_both"],
        "sessions_mcp_only": s["sessions_mcp_only"],
        "sessions_grep_only": s["sessions_grep_only"],
        "discovery_getmcp": s["discovery_getmcp"],
        "webfetch_calls": wf["webfetch_calls"],
        "webfetch_sessions": wf["webfetch_sessions"],
        "ctx_url_read_calls": wf["ctx_url_read_calls"],
        "sessions_webfetch_pct": wf["sessions_webfetch_pct"],
        "tool_result_probe": result["tool_result_probe"],
        "kpi_targets": s["kpi_targets"],
        "pass_search": s["search_mcp_share_pct"] >= 70,
        "pass_read": s["read_mcp_share_pct"] >= 40,
        "pass_dual_sessions": dual["sessions_both_pct"] <= 30,
        "pass_webfetch": wf["webfetch_calls"] <= s["kpi_targets"]["webfetch_calls_target_max"],
    }
    enriched_path.write_text(
        json.dumps(enriched, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    print(json.dumps(enriched, ensure_ascii=False, indent=2))
    print(f"Wrote {raw_path}")
    print(f"Wrote {enriched_path}")


if __name__ == "__main__":
    main()
