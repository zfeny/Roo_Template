# Program Planning (SPEC -> Multi-WO)

## 拆分原则
1. 一个 WO 对应一个可审计交付目标。
2. 一个 WO 至少映射一个 SPEC 条款。
3. NFR 高风险项单独建 WO，避免被功能开发吞掉。

## 推荐产出
1. `03_work_orders/PROGRAM-<date>/01_ProgramPlan.md`（项目级拆分计划）
2. 每个 WO 的 `01_WorkOrder.md`（目标/边界/验收）
3. `04_context_packs/<WO>/04_Decisions_Summary.md`（阶段决策沉淀）

## 排程建议
1. 先做依赖底座 WO，再做功能 WO，最后做收口 WO（文档/风险/发布）。
2. 并行 WO 之间必须写明接口契约与冲突规避策略。
