# Repo Workflow

## 1) 生命周期
1. 创建 WO 骨架：`09_automations/01_scripts/01_new_work_order.sh`。
2. 补全上下文包：`04_context_packs/{WO}/`。
3. 施工实现：`05_src/` 与必要配套。
4. 运行质检：`09_automations/01_scripts/03_run_quality.sh`。
5. 打包交付：`09_automations/01_scripts/04_pack_delivery.sh`。
6. 验收审阅：`08_review_reports/{WO}/`。

## 2) 分支建议
- `wo/WO-YYYYMMDD-XXX-short`

## 3) 最小交付清单
- `06_quality/04_reports/{WO}/01_quality_report.md`
- `06_quality/04_reports/{WO}/02_commands.md`
- `07_delivery_packs/{WO}/01_DeliveryPack.md`
- `07_delivery_packs/{WO}/02_ChangeList.md`
- `07_delivery_packs/{WO}/03_SpecCoverage.md`
- `07_delivery_packs/{WO}/04_Verification.md`
- `07_delivery_packs/{WO}/05_RiskNotes.md`

## 4) Git 约束摘要
1. 严格执行 `10_docs/04_git_workflow.md`。
2. 交互模式与职责边界详见 `10_docs/05_interaction_protocol.md`。
3. 分支命名必须匹配 `wo/<WO_ID>-<slug>`。
4. 提交信息必须以 `<WO_ID>:` 前缀开头。
5. 合并前必须存在 `08_review_reports/<WO_ID>/01_Review.md` 且 `Verdict: PASS`。
