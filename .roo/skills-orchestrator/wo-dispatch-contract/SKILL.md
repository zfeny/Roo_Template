---
name: wo-dispatch-contract
description: Kick off a WO with explicit role assignment, stage ownership, and branch issuance in one pass.
---

# WO Dispatch Contract

Use this skill when issuing a new WO for implementation.

## Steps
1. Generate/switch WO branch and scaffold:
   - `bash .roo_template/09_automations/01_scripts/00_wo.sh kickoff-lean [WO] <slug>`
2. Fill `.roo_template/03_work_orders/{WO}/01_WorkOrder.md` before handoff:
   - Set `Owner` and `Requester`
   - Fill `Role Assignment (Mandatory)` with concrete assignees for `Orchestrator`, `Code`, `Reviewer`
   - Fill `Stage Plan (Mandatory)` owner role per stage
   - Fill objective/scope/DoD/risks
3. Confirm dispatch readiness:
   - Branch is `wo/{WO}-<slug>`
   - WorkOrder has no core-role `TBD`
4. Handoff directly to Code unless risk requires extra roles.

## Output Checklist
- `.roo_template/03_work_orders/{WO}/01_WorkOrder.md` complete
- Branch created and checked
- Explicit assignee + responsibility mapping available for downstream tracking
