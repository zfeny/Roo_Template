# Orchestrator Handoff Flow

## 角色定位
Orchestrator 负责项目级编排与 WO 下发控制，优先让首个 WO 快速进入编码。

## 固定流程（从 SPEC 到合并）
1. Digest SPEC：读取 `_SPECs/` 提取条款、验收、NFR。
2. 先维护 PROGRAM 总包计划：`.roo_process/work_orders/PROGRAM-<YYYYMMDD>/ProgramPlan.md` 与 `TODO.md`。
3. 快速拆分首 WO：形成首个可独立验收 WO，并写入 PROGRAM TODO 对应里程碑。
4. 下发开工令：`python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`。
5. 最小上下文：`python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`。
6. 默认链路：`Orchestrator(parent) -> new_task(Implementation child starts in Librarian) -> switch_mode(Code/Debug as needed) -> return parent -> new_task(Reviewer child) -> return parent`。
7. 发起独立验收：交付 evidence + diff/patch 给 Reviewer。
8. 决策合并：仅 PASS 进入 `main`；FAIL 开 `-R1/-R2` 整改 WO。
9. 合并后仅更新当前 WO 里程碑状态，不得直接宣布项目完成；继续派发下一个 WO 或明确待办。

## 明确边界
1. 总包不做 `src/` 施工实现。
2. 总包负责分支创建与合并决策。
3. 新建 WO 时优先调用技能 `.roo/skills/orchestrator/wo-dispatch-contract/`。
4. 跨边界交接（总包下发施工、总包转交监理）必须用子任务分发（Boomerang/new_task）。
5. 同一 WO 的施工子任务内部允许并鼓励 `switch_mode` 以复用上下文。
6. 多步骤编排必须持续维护 Roo 内置待办清单（`update_todo_list`）。
