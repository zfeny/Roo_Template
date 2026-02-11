# Task Contract

每次发包（下发施工工单）必须包含：

## Input
1. WO ID、目标、范围、非目标。
2. 关联 SPEC 条款与验收标准。
3. 依赖与前置 WO（如有）。
4. 角色分配与职责矩阵（至少明确 Orchestrator/Code/Reviewer 三个核心角色）。
5. 阶段责任表（Kickoff/Build/Quality/Review/Merge 的 owner role）。

## Output
1. 必填路径：`.roo_template/04_context_packs/{WO}`、`.roo_template/07_delivery_packs/{WO}`、`.roo_template/08_review_reports/{WO}`。
2. 可选路径：`.roo_template/06_quality/04_reports/{WO}`。
3. Git 产物：`changes.diff` 或 `changes.patch`。

## Gate
1. 未建立 wo 分支不得开工。
2. `01_WorkOrder.md` 未明确角色分工与阶段 owner 不得进入施工。
3. 未完成 Delivery 包不得发起验收。
4. 未有 `Verdict: PASS` 不得合并。
