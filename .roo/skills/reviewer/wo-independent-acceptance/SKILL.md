---
name: wo-independent-acceptance
description: Perform independent WO acceptance with objective PASS/FAIL and blocking findings. Use in Reviewer mode for final gate decisions.
---

# WO Independent Acceptance

Use this skill in Reviewer mode for final gate decisions.

## Steps
1. Prepare review scaffold: `python3 .roo_process/scripts/wo_flow.py prepare-review --wo <WO_ID>`.
2. Execute gate: `python3 .roo_process/scripts/review_gate.py --feature <WO_ID>`.
3. Validate full package: `python3 .roo_process/scripts/wo_flow.py validate-delivery --wo <WO_ID>`.
4. Write verdict in `.roo_process/review_reports/<WO_ID>/Review.md` with blocking and non-blocking findings.

## Output Checklist
- Review report includes explicit verdict.
- Blocking findings are actionable and traceable.
