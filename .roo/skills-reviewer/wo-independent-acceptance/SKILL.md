---
name: wo-independent-acceptance
description: Perform independent WO acceptance with objective PASS/FAIL and blocking findings.
---

# WO Independent Acceptance

Use this skill in reviewer mode for final gate decisions.

## Steps
1. Prepare review scaffold:
   - `bash .roo_template/09_automations/01_scripts/00_wo.sh prepare-review {WO}`
2. Check evidence set:
   - `.roo_template/07_delivery_packs/{WO}/`
   - `changes.diff` or `changes.patch`
   - referenced quality report(s)
3. Write verdict in `.roo_template/08_review_reports/{WO}/01_Review.md`:
   - `Verdict: PASS` or `Verdict: FAIL`
   - Separate blocking and non-blocking findings
4. If FAIL, list mandatory remediation items and evidence gaps.

## Output Checklist
- Review report includes explicit verdict
- Blocking findings are actionable and traceable
