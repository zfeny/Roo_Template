# Roo Workflow Refactor Baseline (Skills v3)

此仓库已升级为“根目录零流程污染 + Skills v3 + Custom Tools”模式。

## 根目录约定
- `_SPECs/`：Spec 入口（可为空占位）
- `.roo/`、`.roomodes`：Roo 运行配置与 mode/rule/skill 定义
- `.roo_process/`：流程资产（模板、工单、上下文、质量、证据、变更、审查、自动化）
- `src/`：业务代码目录

## 统一流程入口
- `python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`
- `python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`
- `python3 .roo_process/scripts/wo_flow.py prepare-context-all --wo <WO_ID>`
- `python3 .roo_process/scripts/wo_flow.py pack-delivery --wo <WO_ID>`
- `python3 .roo_process/scripts/wo_flow.py prepare-review --wo <WO_ID>`
- `python3 .roo_process/scripts/wo_flow.py validate-delivery --wo <WO_ID>`

## Gate 引擎
- 验收 Gate：`.roo_process/scripts/review_gate.py`
- `evidence.json` 为必备证据（缺失或字段不完整即 FAIL）

## Skills v2 目录
- `.roo/skills/orchestrator/`
- `.roo/skills/code/`
- `.roo/skills/librarian/`
- `.roo/skills/reviewer/`
- `.roo/skills/qa-runner/`
- `.roo/skills/debug/`
- `.roo/skills/architect/`

## 自定义工具（v3）
- 目录：`.roo/tools/`
- 核心工具：
  - `.roo/tools/wo_kickoff.js`
  - `.roo/tools/wo_context.js`
  - `.roo/tools/wo_delivery.js`
  - `.roo/tools/wo_review.js`
  - `.roo/tools/review_gate.js`
- 安全策略：白名单命令构造 + 参数校验 + 禁止 shell 拼接。
- 回退策略：工具失败时回退到 `.roo_process/scripts/wo_flow.py` / `.roo_process/scripts/review_gate.py`。

## 协作策略文档
- `.roo_process/docs/QUEUE_POLICY.md`
- `.roo_process/docs/TODO_POLICY.md`
- `.roo_process/docs/WORKTREE_POLICY.md`
- `.roo_process/docs/TOOLS_POLICY.md`
- `MIGRATION_TOOLS_V3.md`

## 跨服务器快速拉取
- 脚本：`./bootstrap_roo_from_github.sh`
- 用途：从 GitHub 模板仓库同步 `.roo`、`.roomodes`、`.roo_process` 到任意项目目录（可选同步 `_SPECs`）。

## 存量仓 v3 工具迁移
- 脚本：`./migrate_tools_v3.sh`
- 用途：在已有仓库中仅迁移/更新 `.roo/tools` 与 `.roomodes` 的工具优先提示（不改 `src/` 与 `_SPECs`）。
