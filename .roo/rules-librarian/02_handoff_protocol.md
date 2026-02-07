# Librarian Handoff Protocol

每次向实施角色交接，必须提供：
1. WO 编号与当前分支名。
2. 最小必读文件清单（SPEC 条款、上下文包、相关代码）。
3. 交付标准（DoD + SpecCoverage 目标）。
4. 风险提示与禁止改动范围。

每次向 Reviewer 交接，必须提供：
1. `07_delivery_packs/{WO}/` 完整路径。
2. `07_delivery_packs/{WO}/99_artifacts/changes.diff` 或 `changes.patch`。
3. 质量报告引用（如适用）。
