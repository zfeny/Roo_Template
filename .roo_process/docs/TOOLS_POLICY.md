# Tools Policy (v3)

## Objective
Use Roo custom tools as the first-class execution entrypoint for WO orchestration and acceptance, while keeping script fallback for resilience.

## Tool-First Order
1. Prefer `.roo/tools/*.js` for kickoff/context/delivery/review/gate operations.
2. If tool execution fails, fallback to `.roo_process/scripts/wo_flow.py` or `.roo_process/scripts/review_gate.py`.
3. Record fallback reason in evidence (`summary.md` or `Review.md`).
4. Hybrid handoff contract:
   - Boundary crossing: use child tasks (`new_task`) for Orchestrator->Implementation and Orchestrator->Reviewer.
   - Intra-WO implementation: use `switch_mode` inside the active child task.

## Security Controls
1. Commands must be constructed from allowlisted templates only.
2. Reject shell chaining/metacharacters and unsupported subcommands.
3. Validate all tool inputs (`wo`, `slug`, `mode`, `action`, `strict`, `specPaths`) before execution.

## Queue/Todo/Worktree Mapping
1. Queue: high-risk operations are not exposed in custom tools.
2. Todo: tool output warns when WO todo metadata is missing for multi-step flows.
3. Worktree: tool output warns when multiple worktrees are detected and evidence isolation is required.

## Audit Contract
Tool responses must include:
1. `status`
2. `command`
3. `stdout` / `stderr`
4. `artifacts`
5. `warnings`
