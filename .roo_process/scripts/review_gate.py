#!/usr/bin/env python3
"""Roo Review Gate MVP (agent-internal)."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import List, Set, Tuple

FEATURE_PATTERNS = [
    re.compile(r"\bWO-\d{8}-\d+(?:-R\d+)?\b"),
    re.compile(r"\b[A-Z]{2,10}-\d{1,6}\b"),
]
AC_CANONICAL = re.compile(r"\bAC-[A-Za-z0-9_-]+\b")
AC_ADAPTIVE = re.compile(r"\b(?:AC|REQ|NFR|FR)-[A-Za-z0-9_-]+\b")
CR_PATTERN = re.compile(r"\bCR-\d{8}-[A-Za-z0-9._-]+\b")


def run(cmd: List[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, text=True, capture_output=True)


def in_git_repo() -> bool:
    p = run(["git", "rev-parse", "--is-inside-work-tree"])
    return p.returncode == 0 and p.stdout.strip() == "true"


def git_changed_files(base_ref: str | None, head_ref: str) -> Set[str]:
    if not in_git_repo():
        return set()
    if base_ref:
        p = run(["git", "diff", "--name-only", f"{base_ref}...{head_ref}"])
        if p.returncode != 0:
            raise RuntimeError(p.stderr.strip() or "git diff failed")
        return {x.strip() for x in p.stdout.splitlines() if x.strip()}
    p = run(["git", "status", "--porcelain"])
    out: Set[str] = set()
    for line in p.stdout.splitlines():
        line = line.rstrip()
        if not line:
            continue
        raw = line[3:].strip() if len(line) > 3 else line.strip()
        if " -> " in raw:
            raw = raw.split(" -> ", 1)[1].strip()
        out.add(raw)
    return out


def extract_feature(text: str) -> str | None:
    for pat in FEATURE_PATTERNS:
        m = pat.search(text)
        if m:
            return m.group(0)
    return None


def detect_feature_id(explicit: str | None) -> Tuple[str | None, str]:
    if explicit:
        return explicit, "manual --feature"
    if in_git_repo():
        b = run(["git", "branch", "--show-current"]).stdout.strip()
        f = extract_feature(b)
        if f:
            return f, f"branch '{b}'"
        s = run(["git", "log", "-1", "--pretty=%s"]).stdout.strip()
        f = extract_feature(s)
        if f:
            return f, f"commit '{s}'"
    return None, "not found in --feature/branch/commit"


def parse_commands(path: Path) -> List[str]:
    cmds: List[str] = []
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        x = line.strip()
        if not x or x.startswith("#"):
            continue
        if x.startswith("```"):
            continue
        if x.startswith("$"):
            x = x[1:].strip()
        cmds.append(x)
    return cmds


def run_tests(cmds: List[str], logs_dir: Path) -> Tuple[List[str], List[str]]:
    logs_dir.mkdir(parents=True, exist_ok=True)
    ok: List[str] = []
    bad: List[str] = []
    for i, cmd in enumerate(cmds, 1):
        p = subprocess.run(["bash", "-lc", cmd], text=True, capture_output=True)
        log = logs_dir / f"test_{i:02d}.log"
        log.write_text(f"$ {cmd}\n\n[stdout]\n{p.stdout}\n\n[stderr]\n{p.stderr}\n", encoding="utf-8")
        if p.returncode == 0:
            ok.append(f"{cmd} (log: {log})")
        else:
            bad.append(f"{cmd} (exit={p.returncode}, log: {log})")
    return ok, bad


def has_deviation(summary_text: str, commit_subject: str) -> bool:
    checks = [
        r"^\s*(?:[-*]\s*)?SPEC_ALIGNMENT\s*:\s*DEVIATED\s*$",
        r"^\s*(?:[-*]\s*)?SPEC_DEVIATION\s*:\s*(TRUE|YES|1)\s*$",
        r"\b偏离\s*SPEC\b",
    ]
    for pat in checks:
        if re.search(pat, summary_text, re.IGNORECASE | re.MULTILINE):
            return True
    if re.search(r"\bSPEC[-_ ]?DEVIATION\b|\b偏离\s*SPEC\b", commit_subject, re.IGNORECASE):
        return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Roo Review Gate")
    parser.add_argument("--feature", help="Feature id, e.g., WO-20260213-001")
    parser.add_argument("--evidence-root", default=".roo_process/evidence")
    parser.add_argument("--changes-root", default=".roo_process/changes")
    parser.add_argument("--spec-path", action="append", dest="spec_paths", default=None)
    parser.add_argument("--base-ref")
    parser.add_argument("--head-ref", default="HEAD")
    parser.add_argument("--tests-file")
    parser.add_argument("--strict", dest="strict", action="store_true", default=True)
    parser.add_argument("--no-strict", dest="strict", action="store_false")
    args = parser.parse_args()

    passed: List[str] = []
    warns: List[str] = []
    failed: List[str] = []

    feature_id, source = detect_feature_id(args.feature)
    if not feature_id:
        failed.append("Feature-ID 识别失败：请传 --feature 或在分支/提交信息中包含 WO-YYYYMMDD-###")

    spec_paths = args.spec_paths or ["_SPECs"]
    commit_subject = run(["git", "log", "-1", "--pretty=%s"]).stdout.strip() if in_git_repo() else ""

    print("== Roo Review Gate ==")
    print(f"Feature: {feature_id or 'N/A'} (source: {source})")
    print(f"Strict CR: {'ON' if args.strict else 'OFF'}")
    print("SPEC paths: " + ", ".join(spec_paths))

    try:
        changed = git_changed_files(args.base_ref, args.head_ref)
    except RuntimeError as err:
        changed = set()
        failed.append(f"Diff 检查失败: {err}")

    if changed:
        touched = []
        for f in sorted(changed):
            for spec in spec_paths:
                s = spec.rstrip("/")
                if f == s or f.startswith(s + "/"):
                    touched.append(f)
                    break
        if touched:
            failed.append("检测到冻结 SPEC 目录改动: " + ", ".join(touched) + "。请走 CR 变更单。")
        else:
            passed.append("SPEC 冻结目录未被本次 diff 触碰")
    else:
        warns.append("当前 diff 范围无变更文件")

    evidence_dir = Path(args.evidence_root) / (feature_id or "UNKNOWN")
    summary = evidence_dir / "summary.md"
    tests = Path(args.tests_file) if args.tests_file else evidence_dir / "tests.txt"
    ejson = evidence_dir / "evidence.json"

    if not evidence_dir.exists():
        failed.append(f"Evidence 目录缺失: {evidence_dir}")
        summary_text = ""
    else:
        passed.append(f"Evidence 目录存在: {evidence_dir}")
        summary_text = summary.read_text(encoding="utf-8", errors="ignore") if summary.exists() else ""

    if not summary.exists():
        failed.append(f"缺少 summary.md: {summary}")
    else:
        passed.append(f"summary.md 存在: {summary}")

    if not tests.exists():
        failed.append(f"缺少 tests.txt: {tests}")
        cmds = []
    else:
        passed.append(f"tests.txt 存在: {tests}")
        cmds = parse_commands(tests)
        if not cmds:
            failed.append("tests.txt 必须包含至少一条可执行命令")

    ac_refs = sorted(set(AC_CANONICAL.findall(summary_text)))
    if ac_refs:
        passed.append("summary.md AC 引用: " + ", ".join(ac_refs[:8]))
    else:
        adaptive = sorted(set(AC_ADAPTIVE.findall(summary_text)))
        if adaptive:
            passed.append("summary.md 使用自适应 AC 格式: " + ", ".join(adaptive[:8]))
            warns.append("未发现 AC-xxx，已按仓库兼容格式自动适配")
        else:
            failed.append("summary.md 必须包含至少一个 AC-xxx（或 REQ-/NFR-/FR- 兼容格式）")

    if cmds:
        ok, bad = run_tests(cmds, evidence_dir / "logs" / "review_gate_tests")
        passed.extend("Test PASS: " + x for x in ok)
        failed.extend("Test FAIL: " + x for x in bad)

    if ejson.exists():
        try:
            data = json.loads(ejson.read_text(encoding="utf-8"))
            req = {"feature_id", "ac_ids", "commands", "artifacts"}
            if isinstance(data, dict) and req.issubset(data.keys()):
                passed.append("evidence.json 字段完整")
            else:
                warns.append("evidence.json 缺少推荐字段（feature_id/ac_ids/commands/artifacts）")
        except Exception as exc:  # noqa: BLE001
            warns.append(f"evidence.json 解析失败: {exc}")
    else:
        warns.append(f"可选 evidence.json 缺失: {ejson}")

    deviation = has_deviation(summary_text, commit_subject)
    cr_refs = sorted(set(CR_PATTERN.findall(summary_text + "\n" + commit_subject)))
    if deviation and args.strict and not cr_refs:
        failed.append("检测到“偏离 SPEC”标记但未引用 CR-YYYYMMDD-xxx（strict=on）")

    missing_cr = []
    for cr in cr_refs:
        p = Path(args.changes_root) / f"{cr}.md"
        if not p.exists():
            missing_cr.append(str(p))
    if missing_cr:
        failed.append("CR 引用文件缺失: " + ", ".join(missing_cr))
    elif cr_refs:
        passed.append("CR 引用已解析: " + ", ".join(cr_refs))

    print("\n[PASS]")
    for x in passed:
        print("- " + x)
    if warns:
        print("\n[WARN]")
        for x in warns:
            print("- " + x)
    if failed:
        print("\n[FAIL]")
        for x in failed:
            print("- " + x)
        print(f"\nVerdict: FAIL ({len(failed)} issue(s))")
        return 2

    print("\nVerdict: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
