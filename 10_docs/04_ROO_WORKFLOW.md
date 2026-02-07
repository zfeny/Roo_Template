# Roo Workflow Playbook

## Goal
把模式配置、规则文档、自动化脚本联动成一个可验证流程。

## One-Command Path (per WO)
1. `bash 09_automations/01_scripts/01_new_work_order.sh WO-YYYYMMDD-001 short`
   - In Git repos, this command auto creates/switches `wo/WO-YYYYMMDD-001-short`.
2. Fill `03_work_orders/WO-YYYYMMDD-001/01_WorkOrder.md`, then commit `work-order` stage.
3. `bash 09_automations/01_scripts/02_prepare_context.sh WO-YYYYMMDD-001`, then commit `context`.
4. Implement changes, then commit `implementation`.
5. `bash 09_automations/01_scripts/03_run_quality.sh WO-YYYYMMDD-001`, then commit `quality`.
6. `bash 09_automations/01_scripts/04_pack_delivery.sh WO-YYYYMMDD-001`, then commit `delivery`.
7. `bash 09_automations/01_scripts/11_prepare_review.sh WO-YYYYMMDD-001`, fill review, then commit `review`.

## Validation Gates
- 质量阶段：`05_validate_wo.sh {WO} quality`
- 交付阶段：`05_validate_wo.sh {WO} delivery`
- Git 阶段：`06_git_control_check.sh {WO} branch|commit|merge`
- 监理材料：`07_prepare_review_artifacts.sh {WO} wo/{WO}-<slug>`

## Mode Mapping
- `architect`: 设计与计划
- `code`: 施工实现
- `debug`: 问题复现与修复
- `qa-runner`: 质量执行
- `reviewer`: 验收裁决
- `orchestrator`: 跨角色编排

## Git Hooks (Optional)
1. `bash 09_automations/01_scripts/08_install_git_hooks.sh`
2. `commit-msg`：检查 `<WO>:` 提交前缀
3. `pre-push`：检查 WO 分支与合并前提
