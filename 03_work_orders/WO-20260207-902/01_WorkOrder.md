# WO-20260207-902 Work Order

- Branch: wo/WO-20260207-902-roo-sim-flow
- Status: In Progress
- Owner: Orchestrator
- Requester: User

## Objective

完成一次本地 Git 交付闭环演练：从 WO 开工、上下文准备、实现、质检、交付归档、独立评审到合并主分支，且全流程通过脚本化 gate。

## Scope

- 执行并记录 `kickoff-wo`、`prepare-context`、`quality`、`prepare-review`、`git-check-merge`、`merge-wo`。
- 使用阶段提交脚本完成 `work-order/context/implementation/quality/delivery/review` 提交。
- 在 `05_src/app/` 新增最小实现标记文件。
- 生成并核对本 WO 的质量报告与交付工件（含 diff/patch）。

## DoD

- 当前分支满足 `wo/WO-20260207-902-roo-sim-flow`。
- 产物目录齐备：`03_work_orders/WO-20260207-902/` 与 `04_context_packs/WO-20260207-902/`。
- 质量报告齐备：`06_quality/04_reports/WO-20260207-902/`。
- 交付包齐备：`07_delivery_packs/WO-20260207-902/01_DeliveryPack.md` 至 `05_RiskNotes.md`。
- 审查报告存在且 `Verdict: PASS`。

## Risks

- 环境缺少系统 `make`，需通过本地 shim 执行等效 `make` 目标。
- 该 WO 已在历史分支演练过一次，本次以新分支名再次完整演练，需确保提交与合并证据为当前分支链路。
