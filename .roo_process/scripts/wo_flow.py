#!/usr/bin/env python3
"""Unified WO workflow entrypoint for Roo v2."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path
from typing import Iterable, List

ROOT = Path(__file__).resolve().parents[2]
ROO_PROCESS = ROOT / ".roo_process"
TEMPLATES = ROO_PROCESS / "templates"

WO_PATTERN = re.compile(r"^WO-\d{8}-\d+(?:-R\d+)?$")


def run(cmd: List[str], *, cwd: Path = ROOT, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, text=True, capture_output=capture)


def in_git_repo() -> bool:
    p = run(["git", "rev-parse", "--is-inside-work-tree"], capture=True)
    return p.returncode == 0 and p.stdout.strip() == "true"


def assert_wo(wo: str) -> None:
    if not WO_PATTERN.match(wo):
        raise ValueError(f"Invalid WO format: {wo}. Expected WO-YYYYMMDD-###")


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def read_template(name: str, fallback: str) -> str:
    path = TEMPLATES / name
    if path.exists():
        return path.read_text(encoding="utf-8")
    return fallback


def render(text: str, wo: str) -> str:
    return (
        text.replace("WO-YYYYMMDD-001", wo)
        .replace("WO-YYYYMMDD-XXX", wo)
        .replace("{WO}", wo)
    )


def write_if_missing(path: Path, content: str) -> None:
    if path.exists():
        return
    ensure_dir(path.parent)
    path.write_text(content, encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    ensure_dir(path.parent)
    path.write_text(content, encoding="utf-8")


def ensure_work_order(wo: str) -> None:
    base = ROO_PROCESS / "work_orders" / wo
    ensure_dir(base)

    wo_text = render(
        read_template(
            "work_order.md",
            """# Work Order\n\n- WO: `{WO}`\n- Owner:\n- Goal:\n- Scope:\n- Out of Scope:\n\n## Acceptance Mapping\n- AC-001:\n\n## Role Assignment\n- Orchestrator:\n- Architecture:\n- Code:\n- Reviewer:\n""",
        ),
        wo,
    )
    write_if_missing(base / "WorkOrder.md", wo_text)
    write_if_missing(base / "Scope.md", "# Scope\n\n## In Scope\n\n## Out of Scope\n")
    write_if_missing(
        base / "DoD.md",
        "# Definition of Done\n\n- [ ] Work order completed and committed\n- [ ] Context pack completed and committed\n- [ ] Quality evidence completed and committed\n- [ ] Delivery evidence completed and committed\n- [ ] Review report completed and committed\n",
    )


def ensure_context_pack(wo: str) -> None:
    base = ROO_PROCESS / "context_packs" / wo
    ensure_dir(base)
    cp_text = render(read_template("context_pack.md", "# Context Pack\n"), wo)
    write_if_missing(base / "ContextPack.md", cp_text)
    write_if_missing(base / "FileMap.md", "# File Map\n\n## Files\n")
    write_if_missing(base / "API_Contracts.md", "# API Contracts\n\n- N/A\n")
    write_if_missing(base / "Decisions_Summary.md", "# Decisions Summary\n\n- Decision:\n- Reason:\n")


def ensure_quality(wo: str) -> None:
    base = ROO_PROCESS / "quality" / wo
    ensure_dir(base / "logs")
    write_if_missing(
        base / "quality_report.md",
        f"# Quality Report\n\n- WO: `{wo}`\n- Verdict: PENDING\n\n## Checks\n",
    )
    write_if_missing(
        base / "commands.md",
        "# Commands\n\n# One command per line\n",
    )


def ensure_evidence(wo: str) -> None:
    base = ROO_PROCESS / "evidence" / wo
    ensure_dir(base)

    summary_tpl = ROO_PROCESS / "evidence" / "_template" / "summary.md"
    tests_tpl = ROO_PROCESS / "evidence" / "_template" / "tests.txt"
    json_tpl = ROO_PROCESS / "evidence" / "_template" / "evidence.json"

    write_if_missing(
        base / "summary.md",
        render(summary_tpl.read_text(encoding="utf-8") if summary_tpl.exists() else "# Summary\n", wo),
    )
    write_if_missing(
        base / "tests.txt",
        tests_tpl.read_text(encoding="utf-8") if tests_tpl.exists() else "# One command per line\n",
    )
    write_if_missing(
        base / "evidence.json",
        render(
            json_tpl.read_text(encoding="utf-8")
            if json_tpl.exists()
            else '{"feature_id": "{WO}", "ac_ids": ["AC-001"], "commands": [], "artifacts": []}\n',
            wo,
        ),
    )
    delivery_tpl = render(read_template("delivery_pack.md", "# Delivery Pack\n"), wo)
    write_if_missing(base / "DeliveryPack.md", delivery_tpl)
    ensure_dir(base / "artifacts")


def ensure_review_report(wo: str) -> None:
    base = ROO_PROCESS / "review_reports" / wo
    ensure_dir(base)
    review_tpl = render(read_template("review_report.md", "# Review Report\n"), wo)
    write_if_missing(base / "Review.md", review_tpl)


def collect_changed_files(full: bool) -> List[str]:
    if in_git_repo():
        if full:
            p = run(["git", "ls-files"], capture=True)
            if p.returncode == 0:
                return [x for x in p.stdout.splitlines() if x.strip()]
        p = run(["git", "status", "--porcelain"], capture=True)
        if p.returncode == 0:
            files: List[str] = []
            for line in p.stdout.splitlines():
                if not line.strip():
                    continue
                raw = line[3:].strip() if len(line) > 3 else line.strip()
                if " -> " in raw:
                    raw = raw.split(" -> ", 1)[1].strip()
                files.append(raw)
            return sorted(dict.fromkeys(files))
    return sorted(str(p.relative_to(ROOT)) for p in (ROOT / "src").rglob("*") if p.is_file())


def choose_base_ref() -> str | None:
    if not in_git_repo():
        return None
    for ref in ["main", "origin/main", "master", "origin/master"]:
        p = run(["git", "rev-parse", "--verify", ref], capture=True)
        if p.returncode == 0:
            return ref
    return None


def branch_name(wo: str, slug: str) -> str:
    cleaned = re.sub(r"[^a-z0-9-]+", "-", slug.lower()).strip("-")
    return f"wo/{wo}-{cleaned or 'task'}"


def kickoff_lean(wo: str, slug: str) -> int:
    assert_wo(wo)
    ensure_work_order(wo)
    ensure_context_pack(wo)
    ensure_quality(wo)
    ensure_evidence(wo)

    if in_git_repo():
        target = branch_name(wo, slug)
        has_branch = run(["git", "show-ref", "--verify", f"refs/heads/{target}"], capture=True).returncode == 0
        cmd = ["git", "switch", target] if has_branch else ["git", "switch", "-c", target]
        p = run(cmd, capture=True)
        if p.returncode != 0:
            sys.stderr.write(p.stderr)
            return p.returncode
        print(f"Branch ready: {target}")
    else:
        print("WARN: not inside git repository, skipped branch issuance")

    print(f"Kickoff completed for {wo}")
    return 0


def prepare_context(wo: str, full: bool) -> int:
    assert_wo(wo)
    ensure_context_pack(wo)
    files = collect_changed_files(full=full)

    base = ROO_PROCESS / "context_packs" / wo
    title = "Full repository map" if full else "Changed-only map"
    lines = [f"# File Map\n\n## {title}\n"]
    if files:
        lines.extend(f"- `{f}`\n" for f in files)
    else:
        lines.append("- No files detected.\n")
    write_text(base / "FileMap.md", "".join(lines))

    mode = "prepare-context-all" if full else "prepare-context"
    print(f"{mode} completed for {wo} ({len(files)} file(s))")
    return 0


def pack_delivery(wo: str) -> int:
    assert_wo(wo)
    ensure_evidence(wo)
    ensure_quality(wo)

    base_ref = choose_base_ref()
    evidence = ROO_PROCESS / "evidence" / wo
    artifacts = evidence / "artifacts"
    ensure_dir(artifacts)

    changed_files: List[str] = []
    if in_git_repo() and base_ref:
        diff = run(["git", "diff", "--binary", f"{base_ref}...HEAD"], capture=True)
        if diff.returncode == 0:
            write_text(artifacts / "changes.diff", diff.stdout)
        patch = run(["git", "format-patch", f"{base_ref}..HEAD", "--stdout"], capture=True)
        if patch.returncode == 0:
            write_text(artifacts / "changes.patch", patch.stdout)
        changed = run(["git", "diff", "--name-only", f"{base_ref}...HEAD"], capture=True)
        if changed.returncode == 0:
            changed_files = [x for x in changed.stdout.splitlines() if x.strip()]
    else:
        changed_files = collect_changed_files(full=False)

    manifest = [
        "# Delivery Pack\n\n",
        f"- Feature ID: `{wo}`\n",
        f"- Base Ref: `{base_ref or 'N/A'}`\n",
        "- Changed files:\n",
    ]
    manifest.extend(f"  - `{f}`\n" for f in changed_files[:200])
    manifest.extend(
        [
            "\n## Verification Evidence\n",
            f"- `.roo_process/evidence/{wo}/summary.md`\n",
            f"- `.roo_process/evidence/{wo}/tests.txt`\n",
            f"- `.roo_process/evidence/{wo}/evidence.json`\n",
            f"- `.roo_process/quality/{wo}/quality_report.md`\n",
        ]
    )
    write_text(evidence / "DeliveryPack.md", "".join(manifest))

    print(f"pack-delivery completed for {wo}")
    return 0


def prepare_review(wo: str) -> int:
    assert_wo(wo)
    ensure_review_report(wo)
    print(f"prepare-review completed for {wo}")
    return 0


def validate_delivery(wo: str) -> int:
    assert_wo(wo)
    required = [
        ROO_PROCESS / "work_orders" / wo / "WorkOrder.md",
        ROO_PROCESS / "context_packs" / wo / "ContextPack.md",
        ROO_PROCESS / "quality" / wo / "quality_report.md",
        ROO_PROCESS / "quality" / wo / "commands.md",
        ROO_PROCESS / "evidence" / wo / "summary.md",
        ROO_PROCESS / "evidence" / wo / "tests.txt",
        ROO_PROCESS / "evidence" / wo / "evidence.json",
        ROO_PROCESS / "evidence" / wo / "DeliveryPack.md",
    ]

    missing = [str(p.relative_to(ROOT)) for p in required if not p.exists()]
    if missing:
        print("Scaffold FAIL:")
        for p in missing:
            print(f"- Missing: {p}")
        scaffold_ok = False
    else:
        print("Scaffold PASS")
        scaffold_ok = True

    gate = run(["python3", str(ROO_PROCESS / "scripts" / "review_gate.py"), "--feature", wo])
    gate_ok = gate.returncode == 0

    if scaffold_ok and gate_ok:
        print("validate-delivery PASS")
        return 0
    print("validate-delivery FAIL")
    return 2


def parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Roo WO flow v2")
    sub = parser.add_subparsers(dest="command", required=True)

    p_kickoff = sub.add_parser("kickoff-lean", help="Create WO scaffold and switch wo/<WO>-<slug>")
    p_kickoff.add_argument("--wo", required=True)
    p_kickoff.add_argument("--slug", required=True)

    p_ctx = sub.add_parser("prepare-context", help="Build changed-only context pack")
    p_ctx.add_argument("--wo", required=True)

    p_ctx_all = sub.add_parser("prepare-context-all", help="Build full context pack")
    p_ctx_all.add_argument("--wo", required=True)

    p_pack = sub.add_parser("pack-delivery", help="Build delivery evidence pack")
    p_pack.add_argument("--wo", required=True)

    p_review = sub.add_parser("prepare-review", help="Create reviewer scaffold")
    p_review.add_argument("--wo", required=True)

    p_validate = sub.add_parser("validate-delivery", help="Run scaffold + review gate checks")
    p_validate.add_argument("--wo", required=True)

    return parser.parse_args(list(argv))


def main(argv: Iterable[str]) -> int:
    args = parse_args(argv)
    try:
        if args.command == "kickoff-lean":
            return kickoff_lean(args.wo, args.slug)
        if args.command == "prepare-context":
            return prepare_context(args.wo, full=False)
        if args.command == "prepare-context-all":
            return prepare_context(args.wo, full=True)
        if args.command == "pack-delivery":
            return pack_delivery(args.wo)
        if args.command == "prepare-review":
            return prepare_review(args.wo)
        if args.command == "validate-delivery":
            return validate_delivery(args.wo)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
