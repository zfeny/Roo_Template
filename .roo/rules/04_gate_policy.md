# Gate Policy

## Gate A: 准入施工
满足以下条件才允许编码：
1. `.roo_process/work_orders/{WO}/WorkOrder.md` 存在且非空。
2. `WorkOrder.md` 明确 `Role Assignment`，且 Orchestrator/Code/Reviewer 非 `TBD`。
3. `.roo_process/context_packs/{WO}/ContextPack.md` 存在（可最小版）。

## Gate B: 准入验收
满足以下条件才允许 Reviewer 结论：
1. `.roo_process/quality/{WO}/quality_report.md` 存在。
2. `.roo_process/evidence/{WO}/summary.md`、`tests.txt`、`evidence.json`、`DeliveryPack.md` 齐全。
3. `python3 .roo_process/scripts/wo_flow.py validate-delivery --wo {WO}` 返回 PASS。

## Gate C: 准入合并（Git）
满足以下条件才允许并入 `main`：
1. 当前分支满足 `wo/{WO}-<slug>`。
2. 最新提交信息前缀满足 `{WO}: `。
3. `.roo_process/review_reports/{WO}/Review.md` 存在且包含 `Verdict: PASS`。

## Handoff Budget（效率约束）
1. 首个 WO 在进入编码前，必须由 Orchestrator 通过 `new_task` 下发施工子任务。
2. 同一 WO 的施工子任务内部，角色切换使用 `switch_mode`（不新增子任务）以保持上下文连续。
3. 转交独立验收时，必须由 Orchestrator 通过 `new_task` 下发 Reviewer 子任务。
4. 每个子任务结束后必须回到 Orchestrator 父任务，再进行下一次派发或决策。
