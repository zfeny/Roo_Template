# Gate Policy

## Gate A: 准入施工
满足以下条件才允许编码：
1. `.roo_template/03_work_orders/{WO}/01_WorkOrder.md` 存在且非空。
2. `.roo_template/04_context_packs/{WO}/01_ContextPack.md` 存在。

## Gate B: 准入验收
满足以下条件才允许 Reviewer 结论：
1. `.roo_template/06_quality/04_reports/{WO}/01_quality_report.md` 存在。
2. `.roo_template/07_delivery_packs/{WO}/01_DeliveryPack.md` 到 `05_RiskNotes.md` 齐全。
3. `.roo_template/07_delivery_packs/{WO}/04_Verification.md` 引用质量报告路径。

## Gate C: 准入合并（Git）
满足以下条件才允许并入 `main`：
1. 当前分支满足 `wo/{WO}-<slug>`。
2. 最新提交信息前缀满足 `{WO}: `。
3. `.roo_template/08_review_reports/{WO}/01_Review.md` 存在且包含 `Verdict: PASS`。
