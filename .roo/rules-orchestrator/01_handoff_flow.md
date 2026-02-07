# Orchestrator Handoff Flow

## 角色定位
Orchestrator 是总包/PM，不参与施工细节，只做项目级编排与 Git 开工/收工控制。

## 项目级固定流程（从 SPEC 到合并）
1. Digest SPEC：读取 `01_spec_locked/` 提取条款、验收、NFR。
2. 拆分 Program：形成多个可独立验收 WO（必要时含整改 WO）。
3. 下发开工令：创建 `03_work_orders/{WO}/` 并创建分支 `wo/{WO}-<slug>`。
4. 监督施工：要求 Librarian/Architect/Coder/QA 按工序产出证据。
5. 发起独立验收：将 Delivery 包 + diff/patch 转交 Reviewer 独立上下文。
6. 决策合并：仅 PASS 进入 `main`；FAIL 开 `-R1/-R2` 整改 WO。

## 明确边界
1. 总包不进入施工细节讨论。
2. 总包负责分支创建归属与 merge 决策归属。
