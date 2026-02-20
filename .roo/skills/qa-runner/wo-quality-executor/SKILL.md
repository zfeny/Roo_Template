---
name: wo-quality-executor
description: Run deterministic quality checks for a WO and capture auditable evidence. Use when QA Runner must execute test commands, store logs, and produce objective pass/fail outputs.
---

# WO Quality Executor

Run quality checks for a WO and produce objective evidence.

## Workflow
1. Ensure `.roo_process/evidence/<WO_ID>/tests.txt` contains one command per line.
2. Execute commands with `bash .roo/skills/qa-runner/wo-quality-executor/scripts/run_tests_from_file.sh <WO_ID>` and record outputs into `.roo_process/quality/<WO_ID>/logs/`.
3. Update `.roo_process/quality/<WO_ID>/commands.md` and `quality_report.md`.
4. If checks pass, run `python3 .roo_process/scripts/wo_flow.py pack-delivery --wo <WO_ID>`.

## References
- Check profile and report format: `references/check-profile.md`
