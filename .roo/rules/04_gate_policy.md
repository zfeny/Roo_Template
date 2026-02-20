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

## Switch Budget（效率约束）
1. 首个 WO 在进入编码前，默认最多一次模式切换（Orchestrator -> Code）。
2. 若需增加角色切换，必须在 WO 文档中写明触发原因与收益。
