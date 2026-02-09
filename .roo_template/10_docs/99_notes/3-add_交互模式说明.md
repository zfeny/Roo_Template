# 交互模式增补说明（给 Codex / Roo Code 执行用）

> 本文是对当前仓库框架与 `.roo/` 规则体系的**补充协议**：把我们已达成一致的“角色工序 + 上下文隔离 + Git 可追溯 + 本地优先”全都写清楚。
>
> 目标：让 Codex（或任何执行者）按此协议工作时，能够**稳定复现**同一套流程，而不是临场发挥。

---

## 0. 总体设计：多角色、单工单、两阶段（施工/验收）

### 0.1 不是“一个子任务=一个角色”

* 一个子任务（施工工单）内部会**切换多个角色模式**完成：资料员 →（Architect/Coder/…）→（可选质检）→资料员。
* **不新开子任务**来切角色；在同一施工上下文中“模式切换”即可。

### 0.2 监理（Reviewer）必须独立上下文

* Reviewer **不能与施工工单共享上下文**，避免污染与确认偏差。
* Reviewer 只在**独立验收工单/独立会话**中工作。

### 0.3 两阶段闭环

* **施工阶段**：产出可运行实现 + 报验证据包。
* **验收阶段**：只读证据包 + diff/patch → PASS/FAIL。

---

## 1. 角色与职责（5+2）

> 角色固定，职责固定，交付物固定。任何角色不得越权。

### 1) 总包（Orchestrator / PM）

**职责**

* 仅负责：理解 SPEC、编排工序、发包（下发施工工单）、收包（接收交付物）、转交监理验收、依据验收决定是否合并。
* **不参与施工工单的讨论与实现细节**。

**关键权限**

* 负责创建 Git 施工分支（开工令）。
* 负责触发/发起独立验收工单给 Reviewer。
* 负责合并到 `main`（仅当 PASS）。

**交付物**

* `03_work_orders/<WO_ID>/01_WorkOrder.md`
* （可选）`PLAN.md` / `TASKS.md`（如果你后续需要更细分的调度）

### 2) 资料员 / 文控（Librarian / Document Controller）

**职责**

* 施工前：准备 Context Pack（最小必要资料、相关文件摘要、约束提醒）。
* 施工后：整理归档、固化交付证据包（Delivery Pack）。
* 负责把可验证信息写成“证据”，让监理无需知道施工过程也能验收。

**关键权限**

* 允许在既定 `wo/<WO_ID>-*` 分支内提交资料与归档文件。
* 不负责创建施工分支（原则上由总包负责；只有补救时允许，并需记录原因）。

**交付物**

* `04_context_packs/<WO_ID>/01_ContextPack.md` 等
* `07_delivery_packs/<WO_ID>/01_DeliveryPack.md` 等

### 3) 设计院 / 总工（Architect）

**职责**

* 设计模块边界、接口合约、关键取舍与风险护栏。

**交付物（在施工分支内）**

* 设计说明可落在 `10_docs/` 或 `04_context_packs/` 的附加文件（由资料员归档到 Delivery Pack 中引用）。

### 4) 分包施工队（Coder）

**职责**

* 按工单与设计护栏实现代码。
* 只做实现，不做终审裁决。

**交付物**

* `05_src/` 代码改动
* （如要求）`06_quality/01_tests/` 或其他测试内容

### 5) 监理（Reviewer）

**职责**

* 只在独立验收上下文中工作。
* 只基于证据包与差异进行 **PASS/FAIL**。

**明确约束**

* 不参与施工过程。
* 不在施工分支里“边看边改”。

**交付物**

* `08_review_reports/<WO_ID>/01_Review.md`（包含 Verdict: PASS/FAIL + Blocking/Non-blocking）

### +A) 质检员（QA Runner / Test Runner）

**职责**

* 只负责“能否执行/测试结果”，提供客观证据。
* **绝不能代替监理给 PASS/FAIL**。

**何时介入**

* 可选构件：当工单涉及可运行代码、影响面大、或指定需要验证时介入。
* 介入时机：实现完成后、资料员归档前。

**交付物**

* `06_quality/04_reports/<WO_ID>/01_quality_report.md`（事实报告）

### +B) SPEC Owner（业主/需求方）

**职责**

* 编写并锁定 SPEC，放入不可随意修改的目录。

**交付物**

* `01_spec_locked/01_SPEC.md`
* `01_spec_locked/02_ACCEPTANCE.md`

---

## 2. 工单与目录映射（本地 Git 版）

### 2.1 工单 ID 规范

* 工单以目录为权威：`03_work_orders/<WO_ID>/`
* 推荐：`WO-YYYYMMDD-001`（当日自增）

### 2.2 一工单一分支

* `wo/<WO_ID>-<slug>`
* 分支必须与工单目录一一对应。

---

## 3. 两阶段工序（必须照做）

### 3.1 施工工单（Implementation Ticket）——共享上下文，多角色切换

**固定流程**

1. 总包下发工单（创建 `03_work_orders/...`）并创建施工分支 `wo/<WO_ID>-...`
2. 资料员准备 Context Pack（`04_context_packs/...`）
3. Architect/Coder 轮换施工（同一上下文内切模式，不新开子任务）
4. （可选）质检员跑验证并输出报告（`06_quality/...`）
5. 资料员归档固化，组装 Delivery Pack（`07_delivery_packs/...`）
6. 回报总包：提交 Delivery Pack 完成（施工阶段结束）

**注意**

* 施工阶段允许讨论、试错、临时方案。
* 但归档阶段必须把“最终可验收事实”写进 Delivery Pack。

### 3.2 验收工单（Acceptance Ticket）——独立上下文

**固定流程**

1. 总包在独立上下文中向监理发起验收请求（不携带施工对话/试错过程）
2. 监理只读材料：

   * `07_delivery_packs/<WO_ID>/`
   * `diff` 或 `patch`（可存放在 `07_delivery_packs/<WO_ID>/99_artifacts/`）
   * （可选）质检摘要引用
3. 监理输出 `08_review_reports/<WO_ID>/01_Review.md`，给出 PASS/FAIL
4. 总包依据 PASS/FAIL 决定是否合并到 `main`

---

## 4. 证据包（Delivery Pack）必须包含什么

> 监理只看证据包，所以证据包就是“报验资料”。

`07_delivery_packs/<WO_ID>/` 最少包含：

* `01_DeliveryPack.md`（总览）
* `02_ChangeList.md`（改了哪些文件 + 目的）
* `03_SpecCoverage.md`（覆盖哪些 SPEC 条款，哪些未覆盖/部分覆盖）
* `04_Verification.md`（如何验证；如有质检，引用质量报告路径）
* `05_RiskNotes.md`（已知限制、影响面、回滚建议）
* `99_artifacts/changes.diff` 或 `changes.patch`（建议）

---

## 5. Git 约束（本地优先，少即是多）

### 5.1 分支创建归属

* **施工分支由总包创建**（开工令）。
* 资料员原则上不创建施工分支；若补救创建，需在 Delivery Pack 中记录原因。

### 5.2 合并规则

* 只有当 `08_review_reports/<WO_ID>/01_Review.md` 包含 `Verdict: PASS` 才允许合并。
* 推荐 `--no-ff` 合并保留审计节点。

### 5.3 FAIL 的处理

* 监理 FAIL 不在原工单无限循环。
* 总包开整改工单：`<WO_ID>-R1`、`<WO_ID>-R2`…，形成清晰审计链。

### 5.4 质检的定位

* 质检 = 客观事实报告（能否执行/测试结果）。
* 监理 = 最终裁决（PASS/FAIL）。

---

## 6. Roo Code 文件与本协议的关系

### 6.1 `.roo/` 规则目录

* `.roo/rules/`：通用规则
* `.roo/rules-<modeSlug>/`：各角色模式专属规则（你已创建）

### 6.2 `.roomodes`

* 用于声明自定义模式（librarian / qa-runner / reviewer / orchestrator 等），并可用权限组限制工具。

### 6.3 本增补文档的落点（请 Codex 创建）

* **新增文件：** `10_docs/05_interaction_protocol.md`
* 并在 `.roo/rules/02_repo_workflow.md` 中添加引用：

  * “交互模式与职责边界详见 `10_docs/05_interaction_protocol.md`”。

---

## 7. 执行清单（最小 Checklist）

合并前必须满足：

* [ ] `03_work_orders/<WO_ID>/01_WorkOrder.md` 存在
* [ ] `04_context_packs/<WO_ID>/01_ContextPack.md` 存在
* [ ] `07_delivery_packs/<WO_ID>/01_DeliveryPack.md` 存在
* [ ] `08_review_reports/<WO_ID>/01_Review.md` 存在且 Verdict=PASS
* [ ] （如适用）`06_quality/04_reports/<WO_ID>/01_quality_report.md` 已被 `04_Verification.md` 引用

---

## 8. 给 Codex 的明确指令（仅文件动作，不写提示词内容）

Codex 需要在现有框架中：

1. 创建 `10_docs/05_interaction_protocol.md`，内容即本文。
2. 更新 `.roo/rules/02_repo_workflow.md`：追加一行引用到本文件。

> 其它目录结构不变；不得重命名 `.roo/` 与 `.roomodes`；不得修改你已建立的编号目录体系。
