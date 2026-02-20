# Branch Issuance SOP

## 目标
明确“工单创建后即下发施工分支”的操作标准。

## 标准步骤
1. 创建工单骨架并下发分支：`python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`。
2. 脚本自动创建或切换到 `wo/<WO_ID>-<slug>` 并校验分支。
3. 分支确认后再交给 Code 执行施工。

## 异常处理
1. 非 Git 环境：允许继续产物准备，但记录“未启用 Git 管控”。
2. 分支已存在：切换到既有分支并检查是否对应同一 WO。
