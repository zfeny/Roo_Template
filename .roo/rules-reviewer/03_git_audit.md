# Reviewer Git Audit

 Reviewer 在裁决前至少核对：
1. 是否存在 `changes.diff` 或 `changes.patch`。
2. 变更摘要是否能回指 `.roo_process/evidence/{WO}/summary.md` 与 `DeliveryPack.md`。
3. Review 输出后是否由总包执行 merge（Reviewer 不直接 merge）。

若发现“施工过程与验收混合上下文”，应直接标记流程风险并判定 FAIL。
