# Lean Execution Policy

## Objective
缩短“首个 WO 下发到开工”的耗时，在边界隔离前提下最大化同 WO 上下文复用。

## Default Path
1. Use `kickoff-lean` to create WO, switch branch, and prepare minimal context in one step.
2. Dispatch first WO to an implementation child task via `new_task`, starting with Librarian for context hardening and external fact refresh.
3. Librarian must identify at least 3 potentially stale points and run web search for each before coding.
4. Librarian runs `_llmdoc` update-doc, then `switch_mode` to Code.
5. Code completes implementation, then `switch_mode` back to Librarian for post-code `_llmdoc` update-doc.
6. Finish implementation child task and return to Orchestrator.
7. Dispatch independent Reviewer via `new_task` and keep final gate unchanged.

## Handoff Budget
1. Before first implementation commit, default handoff path is one child-task dispatch: `Orchestrator -> Librarian(new_task) -> Code(switch_mode) -> Librarian(switch_mode)`.
2. Same-WO implementation role changes should be `switch_mode`-based, not extra `new_task`.
3. Reviewer handoff must be a separate `new_task` from Orchestrator.
4. "补文档"不构成新增子任务理由，优先在当前 WO 子任务内补齐。

## Escalation Conditions
Switch to full multi-role path when:
1. Architecture risk is high.
2. Cross-module impact is broad.
3. Compliance/audit requirements demand full artifacts.
