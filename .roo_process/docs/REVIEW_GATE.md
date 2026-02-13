# Review Gate (Agent-Driven)

Review Gate 由 agent 在 Roo 对话流程内自动触发，核心引擎：
- `.roo_process/scripts/review_gate.py`

## 检查项（MVP）
1. Feature-ID 识别：`--feature` 优先，否则从 branch / commit message 推断。
2. evidence 检查：`.roo_process/evidence/<FEATURE_ID>/summary.md` 与 `tests.txt` 必须存在。
3. AC 检查：summary 至少包含一个 `AC-xxx`；若仓库使用 `REQ-/NFR-/FR-`，自动适配并给出提示。
4. tests 执行：逐行执行 `tests.txt`（跳过空行和 `#` 注释），失败即 FAIL。
5. CR 严格模式：若 summary/commit 标记“偏离 SPEC”，必须引用 `CR-YYYYMMDD-xxx`，且文件存在（strict 默认开启）。
6. SPEC 冻结检查：默认检查 `_SPECs/` 是否被本次 diff 触碰。

## 证据包模板
- `.roo_process/evidence/_template/summary.md`
- `.roo_process/evidence/_template/tests.txt`
- `.roo_process/evidence/_template/evidence.json`（可选，缺失仅 WARN）
