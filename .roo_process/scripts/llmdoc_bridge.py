#!/usr/bin/env python3
"""Bridge Roo process artifacts into an _llmdoc-style knowledge tree."""

from __future__ import annotations

import argparse
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable, List

ROOT = Path(__file__).resolve().parents[2]
ROO_PROCESS = ROOT / ".roo_process"
LLMDOC = ROOT / "_llmdoc"

WO_PATTERN = re.compile(r"^WO-\d{8}-\d+(?:-R\d+)?$")


def assert_wo(wo: str) -> None:
    if not WO_PATTERN.match(wo):
        raise ValueError(f"Invalid WO format: {wo}. Expected WO-YYYYMMDD-###")


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def write_if_missing(path: Path, content: str) -> None:
    if path.exists():
        return
    ensure_dir(path.parent)
    path.write_text(content, encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    ensure_dir(path.parent)
    path.write_text(content, encoding="utf-8")


def rel(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def init_doc() -> int:
    legacy = ROOT / "llmdoc"
    if legacy.exists() and not LLMDOC.exists():
        legacy.rename(LLMDOC)
        print(f"migrated legacy docs root: {rel(legacy)} -> {rel(LLMDOC)}")

    write_if_missing(
        LLMDOC / "README.md",
        "# _llmdoc Bridge\n\n"
        "This directory is synchronized from Roo process artifacts.\n\n"
        "- Project overview: `01-project/PROJECT_OVERVIEW.md`\n"
        "- Architecture: `02-architecture/ARCHITECTURE.md`\n"
        "- Work order index: `03-work-orders/INDEX.md`\n"
        "- Runbooks: `04-runbooks/QUALITY_GATE.md`\n",
    )
    write_if_missing(
        LLMDOC / "01-project" / "PROJECT_OVERVIEW.md",
        "# Project Overview\n\n"
        "Summarize mission, milestones, and delivery boundaries.\n",
    )
    write_if_missing(
        LLMDOC / "02-architecture" / "ARCHITECTURE.md",
        "# Architecture\n\n"
        "Record system boundaries, key decisions, and tradeoffs.\n",
    )
    write_if_missing(
        LLMDOC / "03-work-orders" / "INDEX.md",
        "# Work Order Index\n\n"
        "| WO | Status | Bridge Doc |\n"
        "|---|---|---|\n",
    )
    write_if_missing(
        LLMDOC / "04-runbooks" / "QUALITY_GATE.md",
        "# Quality Gate Runbook\n\n"
        "Use `.roo_process/scripts/review_gate.py` as final acceptance authority.\n",
    )
    print(f"_llmdoc initialized at {rel(LLMDOC)}")
    return 0


def wo_status(wo: str) -> str:
    review = ROO_PROCESS / "review_reports" / wo / "Review.md"
    if review.exists():
        txt = review.read_text(encoding="utf-8", errors="ignore")
        if "Verdict: PASS" in txt:
            return "PASS"
        if "Verdict: FAIL" in txt:
            return "FAIL"
    return "IN_PROGRESS"


def build_wo_doc(wo: str) -> str:
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%SZ")
    paths = [
        ROO_PROCESS / "work_orders" / wo / "WorkOrder.md",
        ROO_PROCESS / "work_orders" / wo / "DoD.md",
        ROO_PROCESS / "context_packs" / wo / "ContextPack.md",
        ROO_PROCESS / "context_packs" / wo / "Decisions_Summary.md",
        ROO_PROCESS / "quality" / wo / "quality_report.md",
        ROO_PROCESS / "evidence" / wo / "summary.md",
        ROO_PROCESS / "evidence" / wo / "DeliveryPack.md",
        ROO_PROCESS / "review_reports" / wo / "Review.md",
    ]
    lines: List[str] = [
        f"# {wo} Bridge Doc\n\n",
        f"- Updated: {now}\n",
        f"- Status: {wo_status(wo)}\n\n",
        "## Roo Source Artifacts\n",
    ]
    for p in paths:
        mark = "x" if p.exists() else " "
        lines.append(f"- [{mark}] `{rel(p)}`\n")
    lines.extend(
        [
            "\n## Notes\n",
            "- Keep this file as navigation; source of truth remains under `.roo_process/`.\n",
            "- Update from tool: `node .roo/tools/wo_docs.js '{\"action\":\"update-doc\",\"wo\":\""
            + wo
            + "\"}'`.\n",
        ]
    )
    return "".join(lines)


def collect_wos() -> List[str]:
    root = ROO_PROCESS / "work_orders"
    if not root.exists():
        return []
    out: List[str] = []
    for p in sorted(root.iterdir()):
        if p.is_dir() and WO_PATTERN.match(p.name):
            out.append(p.name)
    return out


def update_index() -> None:
    rows = [
        "# Work Order Index\n\n",
        "| WO | Status | Bridge Doc |\n",
        "|---|---|---|\n",
    ]
    for wo in collect_wos():
        rows.append(f"| `{wo}` | {wo_status(wo)} | `03-work-orders/{wo}.md` |\n")
    write_text(LLMDOC / "03-work-orders" / "INDEX.md", "".join(rows))


def update_doc(wo: str) -> int:
    assert_wo(wo)
    init_doc()
    write_text(LLMDOC / "03-work-orders" / f"{wo}.md", build_wo_doc(wo))
    update_index()
    print(f"_llmdoc updated for {wo}: {rel(LLMDOC / '03-work-orders' / f'{wo}.md')}")
    return 0


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Roo <-> _llmdoc bridge")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("init-doc", help="Initialize _llmdoc skeleton")

    p_update = sub.add_parser("update-doc", help="Update bridge doc for a WO")
    p_update.add_argument("--wo", required=True)

    return parser.parse_args(list(argv))


def main(argv: Iterable[str]) -> int:
    args = parse_args(argv)
    try:
        if args.command == "init-doc":
            return init_doc()
        if args.command == "update-doc":
            return update_doc(args.wo)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
