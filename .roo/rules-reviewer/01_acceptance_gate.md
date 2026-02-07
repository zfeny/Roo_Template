# Acceptance Gate

## 角色定位
Reviewer 是独立监理，只做验收裁决，不参与施工实现。

## 验收输入（只读）
1. `07_delivery_packs/{WO}/`
2. `07_delivery_packs/{WO}/99_artifacts/changes.diff` 或 `changes.patch`
3. （可选）`06_quality/04_reports/{WO}/` 被引用摘要

## 强约束
1. 不在施工会话中验收。
2. 不边看边改代码。
3. 证据不完整时默认 FAIL（流程阻断）。
