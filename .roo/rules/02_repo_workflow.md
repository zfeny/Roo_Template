# Repo Workflow

## 1) 生命周期
1. 先更新总包计划：维护 `.roo_process/work_orders/PROGRAM-<date>/ProgramPlan.md` 与 `TODO.md`（里程碑、WO 映射、状态）。
2. 创建 WO 骨架并签出分支：优先 `.roo/tools/wo_kickoff.js`，失败回退 `python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`。
3. 生成最小上下文：优先 `.roo/tools/wo_context.js`（mode=changed），失败回退 `python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`。
4. 由 Orchestrator 使用 `new_task` 下发施工子任务（Librarian 起步）。
5. Librarian 阶段（强制）：基于 WO 内容先提出至少 3 个“可能落后点”，逐项联网检索并记录来源到 `Decisions_Summary.md`。
6. Librarian 阶段（强制）：执行 `_llmdoc` 同步（`wo_docs update-doc`），然后 `switch_mode` 到 Code。
7. Code 阶段：施工实现并更新 `src/` 与必要过程文档。
8. Code 阶段结束：`switch_mode` 回 Librarian。
9. Librarian 阶段（强制）：Code 完成后再次执行 `_llmdoc` 同步（`wo_docs update-doc`）。
10. 更新质量证据：补齐 `.roo_process/quality/<WO_ID>/quality_report.md` 与 `commands.md`。
11. 打包交付证据：优先 `.roo/tools/wo_delivery.js`（action=pack），失败回退 `python3 .roo_process/scripts/wo_flow.py pack-delivery --wo <WO_ID>`。
12. 结束施工子任务并回到 Orchestrator 父任务。
13. 准备审查骨架：优先 `.roo/tools/wo_review.js`，失败回退 `python3 .roo_process/scripts/wo_flow.py prepare-review --wo <WO_ID>`。
14. 由 Orchestrator 使用 `new_task` 下发 Reviewer 子任务做独立验收。
15. 结束 Reviewer 子任务并回到 Orchestrator 父任务。
16. 执行总校验：优先 `.roo/tools/wo_delivery.js`（action=validate）和 `.roo/tools/review_gate.js`，失败回退 `python3 .roo_process/scripts/wo_flow.py validate-delivery --wo <WO_ID>`。
17. 回写 PROGRAM TODO 状态：仅标记当前 WO 对应里程碑完成；若仍有未完成里程碑，不得宣称项目完成。

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
- `_llmdoc/03-work-orders/<WO_ID>.md`

## 4) Git 约束摘要
1. 分支命名必须匹配 `wo/<WO_ID>-<slug>`。
2. 提交信息必须以 `<WO_ID>:` 前缀开头。
3. 合并前必须存在 `.roo_process/review_reports/<WO_ID>/Review.md` 且 `Verdict: PASS`。

## 5) Chat-Only 执行约定
1. 流程命令用于 Agent 内部执行，不要求用户手动执行。
2. 汇报必须包含结果、证据路径、失败原因与修复动作。
3. 多步骤任务必须在会话内维护 Roo 内置待办清单（`update_todo_list`）。
