# Efficiency Policy

1. Default context mode is changed-only:
   - `bash .roo_template/09_automations/01_scripts/00_wo.sh prepare-context {WO}`
   - Use full map only when needed: `prepare-context-all`.
2. Default quality mode is fast for collaboration loops:
   - `quality` = fast profile
   - `quality-full` = full test suites before final review.
3. Delivery artifacts default to `changes.diff`; generate `changes.patch` only when reviewers explicitly need patch format.
4. Keep gates unchanged: review and merge checks remain mandatory.
5. Prefer mode-local Roo Skills to reduce prompt repetition and mode churn:
   - Orchestrator: `.roo/skills-orchestrator/wo-dispatch-contract/`
   - Code: `.roo/skills-code/wo-lean-build/`
   - Reviewer: `.roo/skills-reviewer/wo-independent-acceptance/`
