# Repo Workflow

## 1) 生命周期
1. 先更新总包计划：维护 `.roo_process/work_orders/PROGRAM-<date>/ProgramPlan.md` 与 `TODO.md`（里程碑、WO 映射、状态）。
2. 创建 WO 骨架并签出分支：优先 `.roo/tools/wo_kickoff.js`，失败回退 `python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`。
3. 生成最小上下文：优先 `.roo/tools/wo_context.js`（mode=changed），失败回退 `python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`。
4. 由 Orchestrator 使用 `new_task` 下发施工子任务（Librarian 起步），先补全上下文与外部资料核验，再进入 Code。
5. 同一 WO 施工子任务中按需 `switch_mode`（Librarian/Code/Debug）复用上下文，不新开子任务。
6. 施工实现：更新 `src/` 与必要过程文档。
7. 更新质量证据：补齐 `.roo_process/quality/<WO_ID>/quality_report.md` 与 `commands.md`。
8. 打包交付证据：优先 `.roo/tools/wo_delivery.js`（action=pack），失败回退 `python3 .roo_process/scripts/wo_flow.py pack-delivery --wo <WO_ID>`。
9. 结束施工子任务并回到 Orchestrator 父任务。
10. 准备审查骨架：优先 `.roo/tools/wo_review.js`，失败回退 `python3 .roo_process/scripts/wo_flow.py prepare-review --wo <WO_ID>`。
11. 由 Orchestrator 使用 `new_task` 下发 Reviewer 子任务做独立验收。
12. 结束 Reviewer 子任务并回到 Orchestrator 父任务。
13. 执行总校验：优先 `.roo/tools/wo_delivery.js`（action=validate）和 `.roo/tools/review_gate.js`，失败回退 `python3 .roo_process/scripts/wo_flow.py validate-delivery --wo <WO_ID>`。
14. 回写 PROGRAM TODO 状态：仅标记当前 WO 对应里程碑完成；若仍有未完成里程碑，不得宣称项目完成。

## 2) 分支建议
- `wo/WO-YYYYMMDD-XXX-short`

## 3) 最小交付清单
- `.roo_process/work_orders/<WO_ID>/WorkOrder.md`
- `.roo_process/context_packs/<WO_ID>/ContextPack.md`
- `.roo_process/quality/<WO_ID>/quality_report.md`
- `.roo_process/quality/<WO_ID>/commands.md`
- `.roo_process/evidence/<WO_ID>/summary.md`
- `.roo_process/evidence/<WO_ID>/tests.txt`
- `.roo_process/evidence/<WO_ID>/evidence.json`
- `.roo_process/evidence/<WO_ID>/DeliveryPack.md`
- `.roo_process/review_reports/<WO_ID>/Review.md`

## 4) Git 约束摘要
1. 分支命名必须匹配 `wo/<WO_ID>-<slug>`。
2. 提交信息必须以 `<WO_ID>:` 前缀开头。
3. 合并前必须存在 `.roo_process/review_reports/<WO_ID>/Review.md` 且 `Verdict: PASS`。

## 5) Chat-Only 执行约定
1. 流程命令用于 Agent 内部执行，不要求用户手动执行。
2. 汇报必须包含结果、证据路径、失败原因与修复动作。
3. 多步骤任务必须在会话内维护 Roo 内置待办清单（`update_todo_list`）。
