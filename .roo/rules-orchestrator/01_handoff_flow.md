# Orchestrator Handoff Flow

## 角色定位
Orchestrator 是总包/PM，负责项目级编排与 Git 开工/收工控制，默认优先首工单快速下发。

## 项目级固定流程（从 SPEC 到合并）
1. Digest SPEC：读取 `.roo_template/01_spec_locked/` 提取条款、验收、NFR。
2. 快速拆分首 WO：先形成首个可独立验收 WO，剩余 WO 可并行细化。
3. 下发开工令：优先执行 `bash .roo_template/09_automations/01_scripts/00_wo.sh kickoff-lean [WO] <slug>`。
4. 精简链路施工：默认 `Orchestrator -> Code -> Reviewer`，其余角色按风险按需介入。
5. 发起独立验收：将 Delivery 包 + diff/patch 转交 Reviewer 独立上下文。
6. 决策合并：仅 PASS 进入 `main`；FAIL 开 `-R1/-R2` 整改 WO。

## 明确边界
1. 总包不做 `src/` 施工实现，但可完成 WO/Context 的最小骨架以避免模式抖动。
2. 总包负责分支创建归属与 merge 决策归属。
3. 未经必要性判断，不得为“补文档”频繁切换到 Librarian。
4. 新建 WO 时优先调用技能 `.roo/skills-orchestrator/wo-dispatch-contract/`，确保角色分工一次性写清。
