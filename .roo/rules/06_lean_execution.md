# Lean Execution Policy

## Objective
缩短“首个 WO 下发到开工”的耗时，避免无效模式切换。

## Default Path
1. Use `kickoff-lean` to create WO, switch branch, and prepare minimal context in one step.
2. Dispatch first WO to Code immediately after kickoff; do not block on full context pack.
3. Continue with Code mode for implementation + required process docs when no explicit librarian request exists.
4. Keep Reviewer independent and final gate unchanged.

## Mode Switch Budget
1. Before first implementation commit, default allowed switch count is `Orchestrator -> Code`.
2. Additional switches require explicit risk trigger in WO notes.
3. "补文档"不构成强制切换理由，优先由当前模式补齐。

## Escalation Conditions
Switch to full multi-role path when:
1. Architecture risk is high.
2. Cross-module impact is broad.
3. Compliance/audit requirements demand full artifacts.
