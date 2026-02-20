# Program Planning (SPEC -> Multi-WO)

## 拆分原则
1. 一个 WO 对应一个可审计交付目标。
2. 一个 WO 至少映射一个 SPEC 条款。
3. NFR 高风险项单独建 WO。

## 推荐产出
1. `.roo_process/work_orders/PROGRAM-<date>/ProgramPlan.md`（项目级拆分计划）
2. `.roo_process/work_orders/PROGRAM-<date>/TODO.md`（里程碑、WO 映射、状态、阻塞项；可基于 `.roo_process/templates/program_todo.md`）
3. 每个 WO 的 `WorkOrder.md`（目标/边界/验收）
4. `.roo_process/context_packs/<WO>/Decisions_Summary.md`（阶段决策沉淀）

## 排程建议
1. 先做依赖底座 WO，再做功能 WO，最后做收口 WO。
2. 并行 WO 之间必须写明接口契约与冲突规避策略。

## 完成判定
1. 单个 WO 完成仅更新对应里程碑，不等于 PROGRAM 完成。
2. 仅当 PROGRAM TODO 中全部里程碑完成且所有 WO 有 Reviewer PASS，才允许声明“项目完成”。
