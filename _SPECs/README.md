# _SPECs

`_SPECs/` 是项目唯一 Spec 文档入口。

规则：
- 实现阶段不直接修改 `_SPECs/`。
- 若需求变更，先在 `.roo_process/changes/` 建立 CR，再由流程评审决定是否更新 Spec。
- Review Gate 会在 diff 中检测 `_SPECs/` 改动并阻断。
