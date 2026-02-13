# Vibe Coding 工序化 Git 仓库结构（给 Codex 生成用）

> 约束：**除 `srv/` 外，所有一级目录必须带数字前缀**，确保排序清晰。

## 01 — SPEC（只读权威）

* `01_spec_locked/`

  * `01_SPEC.md`
  * `02_ACCEPTANCE.md`
  * `03_GLOSSARY.md`
  * `04_NFR.md`（可选：性能/安全/可用性等非功能需求）
  * `99_attachments/`（可选：图、表、外部引用）

## 02 — 模板库（稳定格式）

* `02_templates/`

  * `01_work_order.md`
  * `02_context_pack.md`
  * `03_delivery_pack.md`
  * `04_review_report.md`
  * `05_acceptance_request.md`（如果你未来接 GitHub/GitLab）
  * `99_snippets/`（可选：常用片段）

## 03 — 工单（总包权威来源，替代 Issue）

* `03_work_orders/`

  * `WO-YYYYMMDD-001/`

    * `01_WorkOrder.md`
    * `02_Scope.md`（可选：范围更细拆）
    * `03_DoD.md`（可选：完成定义）
    * `99_refs/`（可选：引用资料）

## 04 — Context Pack（资料员施工前准备）

* `04_context_packs/`

  * `WO-YYYYMMDD-001/`

    * `01_ContextPack.md`
    * `02_FileMap.md`（相关文件列表与职责）
    * `03_API_Contracts.md`（接口摘要，可选）
    * `04_Decisions_Summary.md`（历史决策摘要，可选）
    * `99_extracts/`（摘录片段，可选）

## 05 — 施工产出（分包实现区 / 真实业务代码）

* `05_src/`

  * `app/`（你的应用代码）
  * `lib/`（可复用库）
  * `modules/`（按域拆分）
  * `assets/`（静态资源）

## 06 — 测试与质检（质检员输出证据，不下结论）

* `06_quality/`

  * `01_tests/`
  * `02_lint/`
  * `03_security/`（可选：静态扫描规则/报告）
  * `04_reports/`

    * `WO-YYYYMMDD-001/`

      * `01_quality_report.md`
      * `02_commands.md`（跑了哪些命令）
      * `03_logs/`（可选）

## 07 — Delivery Pack（资料员归档，监理只读输入）

* `07_delivery_packs/`

  * `WO-YYYYMMDD-001/`

    * `01_DeliveryPack.md`
    * `02_ChangeList.md`（改了哪些文件+目的）
    * `03_SpecCoverage.md`（覆盖哪些条款）
    * `04_Verification.md`（引用质检报告/命令）
    * `05_RiskNotes.md`（已知限制/影响面/回滚说明）
    * `99_artifacts/`（patch、截图等可选）

## 08 — Review Reports（监理验收结论，独立上下文产物）

* `08_review_reports/`

  * `WO-YYYYMMDD-001/`

    * `01_Review.md`（PASS/FAIL + Blocking/Non-blocking）
    * `02_Blockers.md`（可选：必须整改项清单）
    * `03_FollowUps.md`（可选：后续建议）

## 09 — Automations（脚本/钩子/命令集合）

* `09_automations/`

  * `01_scripts/`

    * `01_new_work_order.sh`（创建工单骨架，可选）
    * `02_prepare_context.sh`（资料员准备包，可选）
    * `03_run_quality.sh`（质检命令入口，可选）
    * `04_pack_delivery.sh`（归档打包，可选）
  * `02_git_hooks/`（可选：pre-commit / pre-merge 规则）
  * `03_make/`（可选：Makefile 片段）

## 10 — Docs（项目说明，不参与验收输入）

* `10_docs/`

  * `01_README.md`
  * `02_ARCH_OVERVIEW.md`
  * `03_CONTRIBUTING.md`（即使单人也建议保留）
  * `99_notes/`

## srv（不带编号的服务层 / 部署运行相关）

* `srv/`

  * `docker/`
  * `compose/`
  * `caddy/`（可选）
  * `systemd/`（可选）
  * `scripts/`（可选：运维脚本）

---

## Roo Code 项目配置（必须保持文件/目录名，不要改名）

> 说明：你之前要求“除 srv 外所有文件夹都加数字编号”。
> **但 Roo Code 识别的是固定名称 `.roo/` 和 `.roomodes`**，不能改成带数字前缀，否则 Roo 读不到。
> 所以建议把 `.roo/` 当作“工具约定目录”，保持原名；在其内部文件再用数字前缀排序即可。 ([docs.roocode.com](https://docs.roocode.com/features/custom-instructions))

### 1) Workspace 规则（项目级，推荐）

* `.roo/`

  * `rules/`（全模式通用规则）

    * `01_general.md`
    * `02_repo_workflow.md`
  * `rules-code/`（仅 Code 模式）

    * `01_coding_style.md`
    * `02_tests.md`
  * `rules-architect/`（仅 Architect 模式）

    * `01_arch_guardrails.md`
  * `rules-debug/`（仅 Debug 模式，可选）

    * `01_debug_protocol.md`
  * `rules-reviewer/`（你的自定义监理/Reviewer 模式 slug，见下）

    * `01_acceptance_gate.md`

> Roo Code 会递归读取 `.roo/rules/` 和 `.roo/rules-{modeSlug}/` 下的文件，并按文件名排序拼接进 system prompt；同名目录存在且非空时，会优先于老的单文件 `.roorules*` 方案。 ([docs.roocode.com](https://docs.roocode.com/features/custom-instructions))

### 2) 项目级自定义 Modes（可选但很适合你这套“角色工序”）

* `.roomodes`（放在项目根目录；YAML 或 JSON 均可，YAML 推荐）

用途：

* 让你把“总包/资料员/质检员/监理”这些角色做成模式；
* 并通过 `groups` 控制工具权限（比如监理只给 `read`，不给 `edit`/`command`）。 ([docs.roocode.com](https://docs.roocode.com/features/custom-modes))

最小示例（YAML 结构骨架，供 Codex 生成文件用；内容你后面再填）：

* `.roomodes`

  * `customModes:`

    * `- slug: librarian`
    * `- slug: qa-runner`
    * `- slug: reviewer`

> 注意：同 slug 的 project mode（.roomodes）会完全覆盖 global mode；project > global > default。 ([docs.roocode.com](https://docs.roocode.com/features/custom-modes))

### 3) 全局规则（可选，跨项目复用）

* Linux/macOS: `~/.roo/rules/`、`~/.roo/rules-{modeSlug}/`
* Windows: `%USERPROFILE%\.roo\rules\`、`%USERPROFILE%\.roo\rules-{modeSlug}\`
* 加载顺序：global → project（project 冲突优先） ([docs.roocode.com](https://docs.roocode.com/features/custom-instructions))

---

## 分支命名建议（配合此结构）

* `main`
* `wo/WO-YYYYMMDD-001-short`

## 关键约束（给 Codex）

1. **Reviewer 仅看 `07_delivery_packs/` + diff +（可选）`06_quality/04_reports/` 引用**
2. 施工过程可在同一 `wo/` 分支内多角色切换，但监理必须独立上下文。
3. 除 `srv/` 外，所有一级目录必须带数字前缀，保证排序；但 `.roo/` 与 `.roomodes` 必须保持固定名称，不能改名。 ([docs.roocode.com](https://docs.roocode.com/features/custom-instructions))
