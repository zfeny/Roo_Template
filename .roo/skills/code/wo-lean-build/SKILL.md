---
name: wo-lean-build
description: Execute the lean implementation lane for an issued WO with mandatory quality and evidence updates. Use when Code mode owns delivery from first commit to review-ready pack.
---

# WO Lean Build

Use this skill after Orchestrator dispatches a WO.

## Steps
1. Verify prerequisites: branch, `WorkOrder.md`, and `ContextPack.md` exist.
2. Implement scoped changes in `src/` and required process artifacts.
3. Record checks in `.roo_process/evidence/<WO_ID>/tests.txt` and `.roo_process/quality/<WO_ID>/quality_report.md`.
4. Pack delivery: `python3 .roo_process/scripts/wo_flow.py pack-delivery --wo <WO_ID>`.
5. Validate gate: `python3 .roo_process/scripts/wo_flow.py validate-delivery --wo <WO_ID>`.

## Output Checklist
- `src/` changes committed with `<WO_ID>:` prefix.
- `.roo_process/quality/<WO_ID>/` updated.
- `.roo_process/evidence/<WO_ID>/` review-ready.
