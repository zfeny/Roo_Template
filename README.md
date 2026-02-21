# Roo Workflow Refactor Baseline (Skills v3)

此仓库已升级为“根目录零流程污染 + Skills v3 + Custom Tools”模式。

## 根目录约定
- `_SPECs/`：Spec 入口（可为空占位）
- `.roo/`、`.roomodes`：Roo 运行配置与 mode/rule/skill 定义
- `.roo_process/`：流程资产（模板、工单、上下文、质量、证据、变更、审查、自动化）
- `_llmdoc/`：文档知识树（默认启用，资料员负责维护）
- `archive/`：历史/维护归档资产（与 `.roo_process/` 运行期资产隔离）
- `src/`：业务代码目录

## 统一流程入口
- `python3 .roo_process/scripts/wo_flow.py kickoff-lean --wo <WO_ID> --slug <slug>`
- `python3 .roo_process/scripts/wo_flow.py prepare-context --wo <WO_ID>`
- `python3 .roo_process/scripts/wo_flow.py prepare-context-all --wo <WO_ID>`
- `python3 .roo_process/scripts/wo_flow.py pack-delivery --wo <WO_ID>`
- `python3 .roo_process/scripts/wo_flow.py prepare-review --wo <WO_ID>`
- `python3 .roo_process/scripts/wo_flow.py validate-delivery --wo <WO_ID>`
- 默认协作链路：`Orchestrator(parent) -> new_task(Implementation child from Librarian) -> Librarian(pre-code search + _llmdoc update) -> switch_mode(Code) -> switch_mode(Librarian post-code update) -> return parent -> new_task(Reviewer child) -> return parent`
- 总包需维护 `.roo_process/work_orders/PROGRAM-<date>/TODO.md`，单个 WO 完成不等于项目完成。
- PROGRAM TODO 可从 `.roo_process/templates/program_todo.md` 初始化。

## Gate 引擎
- 验收 Gate：`.roo_process/scripts/review_gate.py`
- `evidence.json` 为必备证据（缺失或字段不完整即 FAIL）
- SPEC 冻结检查默认作用于 `_SPECs/`（可用 `--spec-path` 覆盖，或 `--no-spec-freeze` 显式关闭）

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
  - `.roo/tools/wo_docs.js`（_llmdoc bridge：`init-doc` / `update-doc`）
- 安全策略：白名单命令构造 + 参数校验 + 禁止 shell 拼接。
- 回退策略：工具失败时回退到 `.roo_process/scripts/wo_flow.py` / `.roo_process/scripts/review_gate.py`。

## _llmdoc 集成（默认启用 + 强制流程）
- 目标：把 TokenRollAI `cc-plugin` 的文档优先思路映射到 Roo 工作流。
- 文档：`.roo_process/docs/LLMDOC_BRIDGE.md`
- 初始化：`node .roo/tools/wo_docs.js '{"action":"init-doc"}'`
- 同步 WO：`node .roo/tools/wo_docs.js '{"action":"update-doc","wo":"<WO_ID>"}'`
- 责任归属：由 Librarian 在 WO 交接给 Code 前、以及 Code 完成后切回 Librarian 时维护 `_llmdoc/`。
- 说明：`_llmdoc/` 仅作导航与知识组织，流程事实仍以 `.roo_process/` 为权威来源。
- 兼容：若仓库仍有旧 `llmdoc/`，`llmdoc_bridge.py init-doc` 会自动迁移为 `_llmdoc/`。

## 协作策略文档
- `.roo_process/docs/QUEUE_POLICY.md`
- `.roo_process/docs/TODO_POLICY.md`
- `.roo_process/docs/WORKTREE_POLICY.md`
- `.roo_process/docs/TOOLS_POLICY.md`
- `MIGRATION_TOOLS_V3.md`

## 跨服务器快速拉取
- 脚本：`./bootstrap_roo_from_github.sh`
- 用途：从 GitHub 模板仓库同步 `.roo`、`.roomodes`、`.roo_process` 到任意项目目录（可选同步 `_SPECs`）。
- 默认不覆盖本地 `archive/`；仅在显式 `--include-archive` 时同步模板归档。
- `--force` 覆盖前会自动把目标仓 legacy process archive 抢救迁移到 `archive/`。
- 热更新（不影响已存在 WO 资产）：
  - `./bootstrap_roo_from_github.sh --hot-update --dest <target_repo_path>`
  - 仅更新 `.roo`、`.roomodes`、`.roo_process/{scripts,automations,templates,docs}`，保留现有 `work_orders/context_packs/quality/evidence/review_reports/changes`。

## 存量仓 v3 工具迁移
- 脚本：`./migrate_tools_v3.sh`
- 用途：在已有仓库中仅迁移/更新 `.roo/tools` 与 `.roomodes` 的工具优先提示（不改 `src/` 与 `_SPECs`）。
