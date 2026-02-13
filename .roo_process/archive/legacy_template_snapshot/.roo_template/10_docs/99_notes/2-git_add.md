# Git 增补说明（给 Codex 用）

> 目的：把你现有的“总包→资料员→分包→（可选质检）→资料员归档→总包转交监理”工序，**完整落到本地 Git** 上，实现：版本可追溯、证据可审计、监理上下文隔离。

> 适用范围：**单人仓库**（你自己一人使用），但保留未来迁移到 GitHub/GitLab 的扩展空间。

---

## 1. 核心原则（务必遵守）

1. **一工单一分支（施工现场）**：每个工单只在对应 `wo/` 分支上施工。

2. **监理隔离**：Reviewer（监理）不进入施工分支上下文；只看 `07_delivery_packs/` + diff（或 patch）+（可选）质检摘要。

3. **可审计交付**：每个工单必须落地 `DeliveryPack` 和 `ReviewReport`，否则不得合并到 `main`。

4. **少即是多**：早期不引入平台能力（Issue/PR/权限），用文件与命名约定替代。

---

## 2. 分支命名规范（Branch Naming）

* 主干：`main`
* 施工分支：`wo/<WO_ID>-<slug>`

  * 示例：`wo/WO-20260207-001-add-git-policy`

> 约束：`WO_ID` 必须与 `03_work_orders/<WO_ID>/` 文件夹完全一致。

---

## 3. 提交信息规范（Commit Message）

所有 commit 的 message **必须**包含工单号前缀：

* 推荐格式：

  * `WO-20260207-001: <short message>`

### 推荐的阶段性提交点（建议）

1. 工单骨架：

* `WO-...: add work order skeleton`

2. Context Pack：

* `WO-...: add context pack`

3. 代码实现：

* `WO-...: implement <feature>`

4. 质检报告（可选）：

* `WO-...: add quality report`

5. Delivery Pack（必需）：

* `WO-...: add delivery pack`

6. 监理报告（必需）：

* `WO-...: add review report (PASS|FAIL)`

---

## 4. 工单生命周期（Local Git 版）

> 下列步骤全部可由 CLI 执行，适合你“尽量不手动 UI”的目标。

### 4.1 总包创建工单 + 施工分支

1. 基于模板创建工单目录：

* `03_work_orders/<WO_ID>/01_WorkOrder.md`

2. 创建并切换到施工分支：

* `git switch -c wo/<WO_ID>-<slug>`

3. 提交工单骨架：

* `git add 03_work_orders/<WO_ID>`
* `git commit -m "<WO_ID>: add work order"`

> 注：如果你希望工单先落在 `main` 再开分支，也可以；但早期推荐**一开始就在 wo 分支内**保持闭环。

### 4.2 资料员准备 Context Pack

在同一 `wo/` 分支里产出：

* `04_context_packs/<WO_ID>/01_ContextPack.md`
* 相关摘要文件（可选）

提交：

* `git add 04_context_packs/<WO_ID>`
* `git commit -m "<WO_ID>: add context pack"`

### 4.3 分包施工（Architect/Coder 轮换）

* 仅允许修改：`05_src/` 及必要测试/配置
* 不允许修改：`01_spec_locked/`（除非你明确开新工单）

提交：

* `git add ...`
* `git commit -m "<WO_ID>: implement ..."`

### 4.4 质检员（可选）

* 质检员只负责“能否执行/测试结果”，不下结论。
* 将输出落到：

  * `06_quality/04_reports/<WO_ID>/01_quality_report.md`

提交：

* `git add 06_quality/04_reports/<WO_ID>`
* `git commit -m "<WO_ID>: add quality report"`

### 4.5 资料员归档 Delivery Pack（必需）

将报验资料固化为：

* `07_delivery_packs/<WO_ID>/01_DeliveryPack.md`
* `02_ChangeList.md`
* `03_SpecCoverage.md`
* `04_Verification.md`（引用质检报告/命令）
* `05_RiskNotes.md`

提交：

* `git add 07_delivery_packs/<WO_ID>`
* `git commit -m "<WO_ID>: add delivery pack"`

### 4.6 监理验收（独立上下文产物，必需）

> 监理只看：`07_delivery_packs/<WO_ID>/` + diff/patch +（可选）质检摘要

监理输出：

* `08_review_reports/<WO_ID>/01_Review.md`

提交：

* `git add 08_review_reports/<WO_ID>`
* `git commit -m "<WO_ID>: add review report (PASS|FAIL)"`

### 4.7 总包合并到 main（仅当 PASS）

* 当且仅当 `01_Review.md` 内 Verdict 为 PASS，才允许 merge。

合并建议：

* `git switch main`
* `git merge --no-ff wo/<WO_ID>-<slug> -m "Merge <WO_ID>"`

> `--no-ff` 会保留一次“合并节点”，审计更清晰。

---

## 5. 监理隔离：如何准备给 Reviewer 的材料包

**推荐两种方式（由总包执行）：**

### 方式 A：只提供 diff（最简单）

* `git diff main...wo/<WO_ID>-<slug> > 07_delivery_packs/<WO_ID>/99_artifacts/changes.diff`

### 方式 B：导出 patch（更像“报验实物”）

* `git format-patch main..wo/<WO_ID>-<slug> --stdout > 07_delivery_packs/<WO_ID>/99_artifacts/changes.patch`

> 然后监理只看：

* `07_delivery_packs/<WO_ID>/01_DeliveryPack.md`
* `changes.diff` 或 `changes.patch`
  -（可选）`06_quality/04_reports/<WO_ID>/...`

---

## 6. 失败与整改（FAIL 时怎么处理）

* 如果监理 Verdict=FAIL：

  * **不要在同一个工单无限循环**。
  * 总包应创建新工单（整改工单），例如：

    * 原：`WO-20260207-001`
    * 整改：`WO-20260207-001-R1`

> 好处：每次整改都是一条清晰审计链；Delivery/Review 文件不会混在一起。

---

## 7. 可选：轻量门禁（后期再做，不是现在必须）

当你准备“自动阻止错误合并”时，可在 `09_automations/02_git_hooks/` 里提供示例 hooks：

* `pre-merge` 或脚本检查：

  1. `07_delivery_packs/<WO_ID>/01_DeliveryPack.md` 必须存在
  2. `08_review_reports/<WO_ID>/01_Review.md` 必须存在且包含 `Verdict: PASS`

> 单人仓库早期可先靠自律与 checklist；稳定后再加 hook。

---

## 8. Codex 执行要求（生成/补齐哪些文件）

请 Codex 在现有框架基础上新增：

1. `10_docs/04_git_workflow.md`（本文件内容，作为仓库规范的一部分）

并在 `.roo/rules/02_repo_workflow.md` 中增加一段“Git 约束摘要”，只引用本文件路径即可（无需重复全文）。

---

## 9. 最小 Checklist（合并前）

* [ ] 本工单目录存在：`03_work_orders/<WO_ID>/`
* [ ] Context Pack 已提交：`04_context_packs/<WO_ID>/`
* [ ] Delivery Pack 已提交：`07_delivery_packs/<WO_ID>/`
* [ ] Review Report 已提交：`08_review_reports/<WO_ID>/` 且 `Verdict: PASS`
* [ ] （如适用）质检报告已引用：`06_quality/04_reports/<WO_ID>/`

---

> 备注：如果你未来切换到 GitHub/GitLab，本文件可直接映射到 Issue/PR/CI；但在本地 Git 阶段，它已足够让工序跑起来、证据可追溯。
