---
name: wo-lean-build
description: Execute the lean implementation lane for an issued WO with mandatory evidence and minimal role switching.
---

# WO Lean Build

Use this skill after Orchestrator has dispatched a WO.

## Steps
1. Verify WO prerequisites:
   - `01_WorkOrder.md` exists and core roles are assigned
   - Current branch matches `wo/{WO}-<slug>`
2. Implement scoped changes in `src/` and required process artifacts.
3. Run fast quality loop:
   - `bash .roo_template/09_automations/01_scripts/00_wo.sh quality {WO}`
4. Complete delivery pack:
   - `bash .roo_template/09_automations/01_scripts/00_wo.sh pack-delivery {WO}`
5. Validate delivery:
   - `bash .roo_template/09_automations/01_scripts/00_wo.sh validate-delivery {WO}`

## Output Checklist
- `src/` changes committed
- `.roo_template/06_quality/04_reports/{WO}/` complete
- `.roo_template/07_delivery_packs/{WO}/` complete
