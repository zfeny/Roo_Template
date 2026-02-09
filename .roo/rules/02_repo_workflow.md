# Repo Workflow

## 1) 生命周期
1. 创建 WO 骨架：`bash .roo_template/09_automations/01_scripts/00_wo.sh kickoff-wo [WO] <slug>`。
2. 补全上下文包：`bash .roo_template/09_automations/01_scripts/00_wo.sh prepare-context {WO}`。
3. 施工实现：`src/` 与必要配套。
4. 快速质检（默认）：`bash .roo_template/09_automations/01_scripts/00_wo.sh quality {WO}`。
5. 收口质检（推荐）：`bash .roo_template/09_automations/01_scripts/00_wo.sh quality-full {WO}`。
6. 打包交付：`bash .roo_template/09_automations/01_scripts/00_wo.sh commit-delivery {WO}`。
7. 验收审阅：`.roo_template/08_review_reports/{WO}/`。

## 2) 分支建议
- `wo/WO-YYYYMMDD-XXX-short`

## 3) 最小交付清单
- `.roo_template/06_quality/04_reports/{WO}/01_quality_report.md`
- `.roo_template/06_quality/04_reports/{WO}/02_commands.md`
- `.roo_template/07_delivery_packs/{WO}/01_DeliveryPack.md`
- `.roo_template/07_delivery_packs/{WO}/02_ChangeList.md`
- `.roo_template/07_delivery_packs/{WO}/03_SpecCoverage.md`
- `.roo_template/07_delivery_packs/{WO}/04_Verification.md`
- `.roo_template/07_delivery_packs/{WO}/05_RiskNotes.md`

## 4) Git 约束摘要
1. 严格执行 `.roo_template/10_docs/04_git_workflow.md`。
2. 交互模式与职责边界详见 `.roo_template/10_docs/05_interaction_protocol.md`。
3. 分支命名必须匹配 `wo/<WO_ID>-<slug>`。
4. 提交信息必须以 `<WO_ID>:` 前缀开头。
5. 合并前必须存在 `.roo_template/08_review_reports/<WO_ID>/01_Review.md` 且 `Verdict: PASS`。
6. 提交作者应使用角色身份而非本机默认用户：
   - work-order/merge: `Orchestrator`
   - context/delivery: `Librarian`
   - implementation: `Code`
   - quality: `QA-Runner`
   - review: `Reviewer`

## 5) 效率策略
1. Context 默认使用 changed-only 文件映射；仅在需要时使用 full 映射。
2. 交付材料默认导出 `changes.diff`；仅在必要时附加 `changes.patch`。
3. 在不降低 gate 的前提下，优先 fast 流水线，收口阶段再执行 full 质检。

## 6) Chat-Only 执行约定
1. 以上流程命令用于 Agent 内部执行，不作为对用户的手动操作要求。
2. 用户通过对话下达意图；Agent 负责调用脚本并回报结果与证据路径。
