# Roo Workflow Refactor Baseline

此仓库已重构为“根目录零流程污染”模式。

## 根目录约定
- `_SPECs/`：唯一 Spec 入口（流程相关目录中唯一保留在根目录）
- `.roo/`、`.roomodes`：Roo 运行配置
- `.roo_process/`：所有流程资产（模板、工单、证据、变更单、自动化、审计文档）

## 用户交互方式（零手动终端）
- 不要求用户手动执行 Bash/终端命令。
- 在 Roo 对话中切换到 `orchestrator` / `reviewer`（或对应模式）即可触发流程。
- Review 验收由 agent 在对话流程内自动调用 `.roo_process/scripts/review_gate.py`。

## 追溯
- 重构迁移与处置决策：`.roo_process/docs/PHASE0_ASSET_AUDIT.md`
- Review Gate 规范：`.roo_process/docs/REVIEW_GATE.md`
