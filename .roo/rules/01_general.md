# General Rules

## 1) 目标
建立可追溯、可审计、可复核的工序化交付流程。

## 2) 全局硬约束
1. 所有实施类工作必须绑定唯一 WO（`WO-YYYYMMDD-XXX`）。
2. 未建立 `.roo_template/03_work_orders/{WO}` 与 `.roo_template/04_context_packs/{WO}` 前，不进入编码。
3. 未产出 `.roo_template/06_quality/04_reports/{WO}` 与 `.roo_template/07_delivery_packs/{WO}` 前，不声称完成。
4. `.roo_template/01_spec_locked/` 默认为只读权威，除非用户明确要求改动。
5. Roo 过程文件只允许写入 `.roo_template/`；业务代码写入根目录 `src/`。
6. Roo 运行配置固定在根目录：`.roo/` 与 `.roomodes`。

## 3) 证据优先
1. 结论必须可回指文件路径。
2. 口头说明不等于验收证据。
3. 质量结论必须包含执行命令与日志位置。

## 4) 交互模型（Chat-Only）
1. 用户唯一入口是 Roo 对话窗；用户提供目标与反馈，不承担命令执行步骤。
2. 所有脚本调用、检查与文件操作由 Agent 在后台自行完成。
3. 除非用户明确要求手动执行命令，否则不要要求用户在终端重复执行流程命令。
