# Task Contract

每次发包（下发施工工单）必须包含：

## Input
1. WO ID、目标、范围、非目标。
2. 关联 SPEC 条款与验收标准。
3. 依赖与前置 WO（如有）。

## Output
1. 必填路径：`04_context_packs/{WO}`、`07_delivery_packs/{WO}`、`08_review_reports/{WO}`。
2. 可选路径：`06_quality/04_reports/{WO}`。
3. Git 产物：`changes.diff` 或 `changes.patch`。

## Gate
1. 未建立 wo 分支不得开工。
2. 未完成 Delivery 包不得发起验收。
3. 未有 `Verdict: PASS` 不得合并。
