# Branch Issuance SOP

## 目标
明确“工单创建后即下发施工分支”的操作标准。

## 标准步骤
1. 创建工单骨架并下发分支：`bash .roo_template/09_automations/01_scripts/00_wo.sh kickoff-wo {WO} <slug>`。
2. 若在 Git 仓库内，脚本会自动创建/切换到 `wo/{WO}-<slug}` 并校验分支。
4. 分支确认后再交给 Librarian 准备 Context Pack。

## 异常处理
1. 非 Git 环境：允许继续产物准备，但标记为“未启用 Git 管控”。
2. 分支已存在：切换到既有分支并检查是否对应同一 WO。
