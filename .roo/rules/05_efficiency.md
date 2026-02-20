# Efficiency Policy

1. Default context mode is changed-only:
   - `python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`
   - Use full map only when needed: `prepare-context-all`.
2. Delivery artifacts default to `changes.diff`; generate `changes.patch` only when reviewer requests it.
3. Keep review and merge gates strict; optimize only execution path.
4. Prefer mode-local Roo Skills to reduce prompt repetition and mode churn:
   - Orchestrator: `.roo/skills/orchestrator/wo-dispatch-contract/`
   - Orchestrator Queue: `.roo/skills/orchestrator/wo-queue-dispatch/`
   - Code: `.roo/skills/code/wo-lean-build/`
   - Reviewer: `.roo/skills/reviewer/wo-independent-acceptance/`
5. Apply hybrid handoff:
   - Boundary crossing (Orchestrator -> Implementation, Orchestrator -> Reviewer): use `new_task`.
   - Intra-WO implementation role changes: use `switch_mode`.
