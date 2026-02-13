# Roo Workflow Playbook

## Goal
把模式配置、规则文档、自动化脚本联动成一个可验证流程。

## One-Command Path (per WO)
1. `bash .roo_process/automations/01_scripts/00_wo.sh kickoff-wo WO-YYYYMMDD-001 short`
   - In Git repos, this command auto creates/switches `wo/WO-YYYYMMDD-001-short` and checks branch gate.
   - WO can be omitted to auto-generate `WO-YYYYMMDD-001` (daily increment).
2. Fill `.roo_process/work_orders/WO-YYYYMMDD-001/01_WorkOrder.md`, then commit `work-order` stage.
3. `bash .roo_process/automations/01_scripts/00_wo.sh prepare-context WO-YYYYMMDD-001`, then commit `context`.
4. Implement changes, then commit `implementation`.
5. `bash .roo_process/automations/01_scripts/00_wo.sh quality WO-YYYYMMDD-001`, then commit `quality`.
   - Fast profile by default.
6. Before review, run full checks: `bash .roo_process/automations/01_scripts/00_wo.sh quality-full WO-YYYYMMDD-001`.
7. `bash .roo_process/automations/01_scripts/00_wo.sh commit-delivery WO-YYYYMMDD-001`.
8. `bash .roo_process/automations/01_scripts/00_wo.sh prepare-review WO-YYYYMMDD-001`, fill review, then commit `review`.
9. `bash .roo_process/automations/01_scripts/00_wo.sh review-gate WO-YYYYMMDD-001` to run evidence-first acceptance checks.

## Validation Gates
- 质量阶段：`bash .roo_process/automations/01_scripts/00_wo.sh validate-quality {WO}`
- 交付阶段：`bash .roo_process/automations/01_scripts/00_wo.sh validate-delivery {WO}`
- Git 阶段：`bash .roo_process/automations/01_scripts/00_wo.sh git-check-branch|git-check-commit|git-check-merge {WO}`
- 监理材料：`bash .roo_process/automations/01_scripts/00_wo.sh review-artifacts {WO} <slug>`
- Evidence Gate：`bash .roo_process/automations/01_scripts/00_wo.sh review-gate {WO}`

## Mode Mapping
- `architect`: 设计与计划
- `code`: 施工实现
- `debug`: 问题复现与修复
- `qa-runner`: 质量执行
- `reviewer`: 验收裁决
- `orchestrator`: 跨角色编排

## Git Hooks (Optional)
1. `bash .roo_process/automations/01_scripts/08_install_git_hooks.sh`
2. `commit-msg`：检查 `<WO>:` 提交前缀
3. `pre-push`：检查 WO 分支与合并前提
