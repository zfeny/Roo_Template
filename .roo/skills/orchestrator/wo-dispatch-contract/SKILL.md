---
name: wo-dispatch-contract
description: Kick off a new WO with branch issuance, minimal artifacts, and explicit role assignment. Use when Orchestrator needs to start execution quickly with `kickoff-lean` and hand off to Code.
---

# WO Dispatch Contract

Use this skill when issuing a new WO for implementation.

## Steps
1. Run kickoff: `python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`.
2. Confirm `wo/<WO_ID>-<slug>` branch is active.
3. Complete `.roo_process/work_orders/<WO_ID>/WorkOrder.md` with objective, scope, DoD, and role assignment.
4. Generate minimal context: `python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`.
5. Hand off directly to Code unless risk requires extra roles.

## Output Checklist
- `.roo_process/work_orders/<WO_ID>/WorkOrder.md` complete.
- `.roo_process/context_packs/<WO_ID>/ContextPack.md` exists.
- Branch and ownership are explicit for downstream tracking.
