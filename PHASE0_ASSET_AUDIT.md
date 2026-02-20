# Phase 0 - Asset Audit and Refactor Plan

## 1) 资产分类

### 项目本体
- `src/`
- `.vscode/`
- `README.md`

### Roo 流程资产（重构后统一放入 `.roo_process/`）
- templates / work_orders / context_packs / quality / scripts / evidence / changes / docs / automations / review_reports

## 2) 迁移映射（旧 -> 新）
- `legacy_template_root/02_templates/*` -> `.roo_process/templates/*`
- `legacy_template_root/03_work_orders/*` -> `.roo_process/work_orders/*`
- `legacy_template_root/04_context_packs/*` -> `.roo_process/context_packs/*`
- `legacy_template_root/06_quality/*` -> `.roo_process/quality/*`
- `legacy_template_root/09_automations/*` -> `.roo_process/automations/*`
- `legacy_template_root/10_docs/*` -> `.roo_process/docs/*`
- `legacy_template_root/01_spec_locked/*` -> `_SPECs/*`（并取消 spec_locked 概念）
- `changes/*` -> `.roo_process/changes/*`
- `evidence/*` -> `.roo_process/evidence/*`
- `scripts/*` -> `.roo_process/scripts/*`
- `.github/workflows/*` -> `.roo_process/archive/legacy_automations_snapshot/github_workflows/workflows/*`

## 3) 遗留脚本/模板拆解决策
- 保留并迁移：`review_gate.py`（作为统一 Gate 引擎）
- 合并：Review Gate 与关键校验逻辑合并到 `.roo_process/scripts/review_gate.py`
- 归档：legacy Bash / hook / make 脚本迁入 `.roo_process/archive/legacy_automations_snapshot/`
- 归档：根目录 `Makefile` 迁入 `.roo_process/archive/legacy_automations_snapshot/Makefile.legacy_root`
- 废弃入口：根目录 `changes/ evidence/ scripts/ specs/ legacy_template_root/`（已迁移或归档）
- 归档：整套旧模板快照 -> `.roo_process/archive/legacy_template_snapshot/`

## 4) 约束结果
- 根目录流程目录已收敛到 `_SPECs/` + `.roo_process/`。
- `.roo` 与 `.roomodes` 保持根目录。
- 不再使用 `spec_locked` 目录。
