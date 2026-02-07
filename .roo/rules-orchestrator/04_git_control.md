# Git Control Policy

## 开工控制
1. 分支由总包创建：`git switch -c wo/{WO}-<slug>`。
2. 分支与工单目录必须一一对应。
3. 推荐用脚本执行开工：`01_new_work_order.sh` + `06_git_control_check.sh {WO} branch`。

## 过程控制
1. 提交信息前缀必须是 `{WO}: `。
2. 关键阶段至少一条提交：work order/context/implementation/delivery/review。
3. 推荐使用阶段提交脚本：`09_git_commit_stage.sh {WO} <stage>`。

## 验收控制
1. Reviewer 必须在独立上下文验收。
2. 验收输入最小集：`07_delivery_packs/{WO}` + `changes.diff|changes.patch`。

## 合并控制
1. 仅当 `08_review_reports/{WO}/01_Review.md` 含 `Verdict: PASS` 允许 merge。
2. 推荐 `git merge --no-ff wo/{WO}-<slug> -m "Merge {WO}"`。
3. 推荐使用合并脚本：`10_git_merge_wo.sh {WO} <slug>`（含 gate 检查）。
