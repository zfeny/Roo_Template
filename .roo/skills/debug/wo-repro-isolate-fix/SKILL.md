---
name: wo-repro-isolate-fix
description: Debug WO issues with reproduce-isolate-fix discipline and mandatory evidence updates. Use when Debug mode investigates defects or flaky behavior.
---

# WO Repro Isolate Fix

Follow a strict reproduce-isolate-fix loop for WO defects.

## Workflow
1. Reproduce issue with explicit commands and expected/actual behavior.
2. Isolate root cause to the smallest failing unit.
3. Apply minimal patch and rerun targeted checks.
4. Update `.roo_process/quality/<WO_ID>/quality_report.md` and `.roo_process/evidence/<WO_ID>/summary.md`.

## References
- Debug playbook: `references/debug-playbook.md`
