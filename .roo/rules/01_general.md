# General Rules

## 1) 目标
建立可追溯、可审计、可复核的工序化交付流程。

## 2) 全局硬约束
1. 所有实施类工作必须绑定唯一 WO（`WO-YYYYMMDD-XXX`）。
2. 未建立 `.roo_process/work_orders/{WO}` 与 `.roo_process/context_packs/{WO}` 前，不进入编码。
3. 未产出 `.roo_process/quality/{WO}` 与 `.roo_process/evidence/{WO}` 前，不声称完成。
4. 单个 WO 完成不等于项目完成；仅当 PROGRAM 级 TODO 里全部里程碑完成且无待处理 WO，才允许声明“任务完成”。
5. 执行步骤 >= 4 时必须维护 Roo 内置待办清单（`update_todo_list`），且未清空待办不得结束会话任务。
6. `_SPECs/` 默认为只读权威，除非用户明确要求改动。
7. Roo 过程文件只允许写入 `.roo_process/`；业务代码写入根目录 `src/`。

## 3) 证据优先
1. 结论必须可回指文件路径。
2. 口头说明不等于验收证据。
3. 质量结论必须包含执行命令与日志位置。

## 4) 交互模型（Chat-Only）
1. 用户唯一入口是 Roo 对话窗。
2. 所有脚本调用、检查与文件操作由 Agent 在后台自行完成。
3. 除非用户明确要求手动执行命令，否则不要把流程命令抛回给用户。
