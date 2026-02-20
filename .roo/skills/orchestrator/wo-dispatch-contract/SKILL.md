---
name: wo-dispatch-contract
description: Kick off a new WO with branch issuance, minimal artifacts, and explicit role assignment. Use when Orchestrator needs to start execution quickly with `kickoff-lean` and hand off to Code via child task.
---

# WO Dispatch Contract

Use this skill when issuing a new WO for implementation.

## Steps
1. Run kickoff: `python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`.
2. Confirm `wo/<WO_ID>-<slug>` branch is active.
3. Update program-level tracker first: `.roo_process/work_orders/PROGRAM-<YYYYMMDD>/TODO.md` (add WO milestone and owner).
4. Complete `.roo_process/work_orders/<WO_ID>/WorkOrder.md` with objective, scope, DoD, and role assignment.
5. Generate minimal context: `python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`.
6. Dispatch implementation via Boomerang child task (`new_task`) starting in Librarian with WO/context/evidence paths.
7. In the same WO execution child task, role changes should use `switch_mode` (Librarian -> Code -> Debug as needed) to reuse context.
8. When implementation is complete, return to Orchestrator parent and then dispatch Reviewer via a new child task.
9. After review closure, only mark current milestone done; do not mark program complete unless all milestones are closed.

## Output Checklist
- `.roo_process/work_orders/<WO_ID>/WorkOrder.md` complete.
- `.roo_process/context_packs/<WO_ID>/ContextPack.md` exists.
- Child-task handoff payload, in-task role-switch plan, and ownership are explicit for downstream tracking.
