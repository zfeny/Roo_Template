# Git Control Policy

## 开工控制
1. 分支由总包创建：`git switch -c wo/{WO}-<slug>`。
2. 分支与工单目录必须一一对应。
3. 推荐用统一入口脚本执行开工：`bash .roo_template/09_automations/01_scripts/00_wo.sh kickoff-lean {WO} <slug>`。
4. `kickoff-lean` 默认使用 `minimal` 上下文模式，优先保证首个 WO 快速进入编码。
5. 在受限环境中禁止依赖 `make` 命令。

## 过程控制
1. 提交信息前缀必须是 `{WO}: `。
2. 关键阶段至少一条提交：work order/context/implementation/delivery/review。
3. 推荐使用统一入口脚本：`bash .roo_template/09_automations/01_scripts/00_wo.sh commit-<stage> {WO}`。
4. 为提速，默认先走 `quality`（fast）；验收前补一次 `quality-full`。

## 验收控制
1. Reviewer 必须在独立上下文验收。
2. 验收输入最小集：`.roo_template/07_delivery_packs/{WO}` + `changes.diff|changes.patch`。

## 合并控制
1. 仅当 `.roo_template/08_review_reports/{WO}/01_Review.md` 含 `Verdict: PASS` 允许 merge。
2. 推荐 `git merge --no-ff wo/{WO}-<slug> -m "Merge {WO}"`。
3. 推荐使用统一入口脚本：`bash .roo_template/09_automations/01_scripts/00_wo.sh merge-wo {WO} <slug>`（含 gate 检查）。
