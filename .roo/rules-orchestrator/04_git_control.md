# Git Control Policy

## 开工控制
1. 分支由总包创建：`git switch -c wo/{WO}-<slug>`。
2. 推荐统一入口：`python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`。
3. 在受限环境中禁止依赖 `make`。

## 过程控制
1. 提交信息前缀必须是 `{WO}: `。
2. 关键阶段至少一条提交：work-order/context/implementation/evidence/review。
3. 交付前必须执行：`python3 .roo_process/scripts/wo_flow.py pack-delivery --wo <WO_ID>`。

## 验收控制
1. Reviewer 必须在独立上下文验收。
2. 验收输入最小集：`.roo_process/evidence/{WO}` + `changes.diff|changes.patch`。
3. 验收前必须执行：`python3 .roo_process/scripts/wo_flow.py validate-delivery --wo <WO_ID>`。

## 合并控制
1. 仅当 `.roo_process/review_reports/{WO}/Review.md` 含 `Verdict: PASS` 允许 merge。
2. 推荐 `git merge --no-ff wo/{WO}-<slug> -m "Merge {WO}"`。
