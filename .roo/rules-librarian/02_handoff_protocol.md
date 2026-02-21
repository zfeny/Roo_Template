# Librarian Handoff Protocol

每次向实施角色交接，必须提供：
1. WO 编号与当前分支名。
2. 最小必读文件清单（SPEC 条款、ContextPack、相关代码）。
3. 交付标准（DoD + AC 覆盖目标）。
4. 风险提示与禁止改动范围。
5. “至少 3 个可能落后点”的联网检索记录、来源摘要与时效说明（写入 `Decisions_Summary.md`）。
6. `_llmdoc/03-work-orders/{WO}.md` pre-code 同步已完成。

每次向 Reviewer 交接，必须提供：
1. `.roo_process/evidence/{WO}/` 完整路径。
2. `.roo_process/evidence/{WO}/artifacts/changes.diff` 或 `changes.patch`。
3. `.roo_process/quality/{WO}/quality_report.md` 路径。
4. `_llmdoc/03-work-orders/{WO}.md` post-code 同步已完成。
