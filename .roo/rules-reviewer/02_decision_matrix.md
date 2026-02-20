# Decision Matrix

## PASS 条件
1. `summary.md`、`tests.txt`、`evidence.json` 齐全且可复核。
2. AC 映射明确且无关键漏项。
3. `review_gate.py` 执行通过。
4. 风险与回滚说明满足上线前最小要求。

## FAIL 条件
1. 关键证据缺失或互相矛盾。
2. diff/patch 与变更说明无法对齐。
3. 测试失败、CR 缺失或 SPEC 偏离未说明。

## 输出要求
1. `.roo_process/review_reports/{WO}/Review.md` 必须包含 `Verdict: PASS|FAIL`。
2. FAIL 必须列出 blocking 项与整改建议。
