# Queue Policy (Efficiency First)

## Objective
在不放宽验收 gate 的前提下，缩短 Orchestrator 的排队等待时延。

## Auto-Approve Scope (Low Risk)
1. Read-only inspection commands.
2. WO 脚手架和上下文生成（`kickoff-lean`、`prepare-context`、`prepare-context-all`）。
3. 本地确定性校验（不涉及远端写入）。

## Manual Approval Scope (High Risk)
1. `git push` 与任何远端写入。
2. merge/rebase/cherry-pick 等历史整合动作。
3. 破坏性命令（`rm`、`git reset --hard`、force 操作）。

## Evidence
1. 队列决策必须在相关 WO 的 `summary.md` 或 `Review.md` 里可追溯。
