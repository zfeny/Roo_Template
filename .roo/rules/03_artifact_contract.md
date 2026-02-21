# Artifact Contract

## Work Order (`.roo_process/work_orders/{WO}`)
- `WorkOrder.md`: 目标、责任人、范围、分支。
- `Scope.md`: In Scope / Out of Scope。
- `DoD.md`: 完成定义，必须可验证。

## Context Pack (`.roo_process/context_packs/{WO}`)
- `ContextPack.md`: 背景与约束。
- `FileMap.md`: 影响文件与职责映射。
- `API_Contracts.md`: 接口变化摘要（如适用）。
- `Decisions_Summary.md`: 关键决策与取舍。

## Quality (`.roo_process/quality/{WO}`)
- `quality_report.md`: 各检查项 PASS/FAIL。
- `commands.md`: 实际命令。
- `logs/`: 原始输出。

## Delivery Evidence (`.roo_process/evidence/{WO}`)
- `summary.md`: 变更摘要与 AC 映射。
- `tests.txt`: Review Gate 执行命令清单。
- `evidence.json`: 结构化证据索引（必备）。
- `DeliveryPack.md`: 交付概览与引用。
- `artifacts/`: `changes.diff` / `changes.patch` 等附件。

## Review (`.roo_process/review_reports/{WO}`)
- `Review.md`: 独立验收结论（PASS/FAIL + findings）。

## _llmdoc Bridge (`_llmdoc/`)
- `03-work-orders/{WO}.md`: WO 文档导航（由 bridge 脚本/工具维护）。
- `03-work-orders/INDEX.md`: WO 状态索引。
- 注意：`_llmdoc/` 不是验收权威，权威仍在 `.roo_process/*`。
