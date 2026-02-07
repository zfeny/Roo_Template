# WO-20260207-902 Context Pack

## Background

本次 WO 用于执行本地 Git 交付闭环演练，要求覆盖：开工、上下文准备、实现、质检、交付、评审与合并。上下文包目标是为 Gate A 提供可审计证据，并明确后续阶段输入。

## Constraints

- 必须绑定唯一 WO：`WO-20260207-902`。
- 必须在分支 `wo/WO-20260207-902-roo-sim-flow` 施工。
- `01_spec_locked/` 为只读，不在本 WO 修改。
- 全流程通过脚本化 gate，不以口头说明替代证据。
- 环境缺少系统 `make`，采用本地 shim 执行等效 make 目标。

## Key Files

- `03_work_orders/WO-20260207-902/01_WorkOrder.md`：工单目标、范围、DoD 与风险。
- `04_context_packs/WO-20260207-902/01_ContextPack.md`：本上下文基线。
- `04_context_packs/WO-20260207-902/02_FileMap.md`：受影响文件与职责映射。
- `05_src/app/roo_sim_marker.txt`：最小实现标记文件（implementation 阶段新增）。
- `06_quality/04_reports/WO-20260207-902/`：质量报告、命令清单与日志。
- `07_delivery_packs/WO-20260207-902/`：交付包与 `99_artifacts`。
- `08_review_reports/WO-20260207-902/01_Review.md`：独立评审结论，需 `Verdict: PASS`。
