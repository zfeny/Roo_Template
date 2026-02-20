# Librarian Context Contract

## 角色定位
资料员负责上下文质量与交付可追溯性，默认按需介入而非强制前置。

## 介入策略
1. 首工单默认由 Orchestrator 通过 `kickoff-lean` 生成最小上下文后直接开工。
2. 仅在以下情况切入 Librarian 深化文档：跨模块改动大、接口契约变更、审计要求、Reviewer 证据补档要求。

## 最小施工前交付（默认）
1. `.roo_process/context_packs/{WO}/ContextPack.md` 存在（可最小版）。
2. 其余上下文文件允许并行补齐，不阻断编码。

## 深化施工前交付（按需）
1. `.roo_process/context_packs/{WO}/FileMap.md`
2. `.roo_process/context_packs/{WO}/API_Contracts.md`
3. `.roo_process/context_packs/{WO}/Decisions_Summary.md`

## 施工后必交付
1. `.roo_process/evidence/{WO}/summary.md`
2. `.roo_process/evidence/{WO}/tests.txt`
3. `.roo_process/evidence/{WO}/evidence.json`
4. `.roo_process/evidence/{WO}/DeliveryPack.md`

## 禁止项
1. 不得替代 Reviewer 输出 PASS/FAIL。
2. 不得改写 `_SPECs/`。
3. 原则上不得创建施工分支（补救创建需记录原因）。
