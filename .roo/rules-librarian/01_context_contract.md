# Librarian Context Contract

## 角色定位
资料员负责上下文质量与交付可追溯性，是 WO 施工子任务的默认起步角色。

## 介入策略
1. 每个新 WO 在进入 Code 前，先由 Librarian 完成最小上下文核验与交接。
2. Librarian 默认且强制联网搜索：收到 WO 后必须先提出至少 3 个“可能落后点”，逐项检索并记录来源。
3. 当需求涉及时效性信息（外部 API、依赖版本、标准/监管变化）时，必须使用联网搜索补全最新资料并沉淀来源。
4. 在以下情况执行深度上下文补全：跨模块改动大、接口契约变更、审计要求、Reviewer 证据补档要求。

## 最小施工前交付（默认）
1. `.roo_process/context_packs/{WO}/ContextPack.md` 存在（可最小版）。
2. `.roo_process/context_packs/{WO}/Decisions_Summary.md` 记录“3 个可能落后点”、检索过程、来源、时效判断与关键结论。
3. `_llmdoc/03-work-orders/{WO}.md` 完成 pre-code 同步（`wo_docs update-doc`）。
4. 完成交接后才允许 `switch_mode` 到 Code。
5. 其余上下文文件允许并行补齐，不阻断编码。

## 深化施工前交付（按需）
1. `.roo_process/context_packs/{WO}/FileMap.md`
2. `.roo_process/context_packs/{WO}/API_Contracts.md`
3. `.roo_process/context_packs/{WO}/Decisions_Summary.md`
4. 同步维护 `_llmdoc/03-work-orders/{WO}.md` 作为导航索引（源事实仍在 `.roo_process/`）。

## 施工后必交付
1. `.roo_process/evidence/{WO}/summary.md`
2. `.roo_process/evidence/{WO}/tests.txt`
3. `.roo_process/evidence/{WO}/evidence.json`
4. `.roo_process/evidence/{WO}/DeliveryPack.md`
5. Code 完成后切回 Librarian 并执行 `_llmdoc` post-code 同步。

## 禁止项
1. 不得替代 Reviewer 输出 PASS/FAIL。
2. 不得改写 `_SPECs/`。
3. 原则上不得创建施工分支（补救创建需记录原因）。
4. 未完成最小上下文核验不得将施工直接交给 Code。
5. 未完成“3 个可能落后点”联网检索，不得交接 Code。
