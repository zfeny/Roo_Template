# Decision Matrix

## PASS 条件
1. Delivery 包关键文件齐全。
2. SpecCoverage 映射明确且无关键漏项。
3. Verification 可复核且能追溯质量证据。
4. 风险与回滚说明满足上线前最小要求。

## FAIL 条件
1. 关键证据缺失或互相矛盾。
2. diff/patch 与 ChangeList 无法对齐。
3. 存在阻断级质量失败且无可接受缓解。

## 输出要求
1. `.roo_template/08_review_reports/{WO}/01_Review.md` 必须包含 `Verdict: PASS|FAIL`。
2. FAIL 必须列出 blocking 项与整改建议。
