# Orchestrator Handoff Flow

## 角色定位
Orchestrator 负责项目级编排与 WO 下发控制，优先让首个 WO 快速进入编码。

## 固定流程（从 SPEC 到合并）
1. Digest SPEC：读取 `_SPECs/` 提取条款、验收、NFR。
2. 快速拆分首 WO：先形成首个可独立验收 WO。
3. 下发开工令：`python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`。
4. 最小上下文：`python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`。
5. 默认链路：`Orchestrator -> Code -> Reviewer`，其余角色按风险按需介入。
6. 发起独立验收：交付 evidence + diff/patch 给 Reviewer。
7. 决策合并：仅 PASS 进入 `main`；FAIL 开 `-R1/-R2` 整改 WO。

## 明确边界
1. 总包不做 `src/` 施工实现。
2. 总包负责分支创建与合并决策。
3. 新建 WO 时优先调用技能 `.roo/skills/orchestrator/wo-dispatch-contract/`。
