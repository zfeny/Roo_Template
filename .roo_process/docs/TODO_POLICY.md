# Todo Policy

## Objective
保证长链路任务在执行前就具备显式步骤、顺序和完成状态，并避免“提前宣布完成”。

## Mandatory Scope A: Roo Built-in Todo (single session)
1. Orchestrator/Code/Debug/Librarian/Reviewer/QA 在任务步骤 >= 4 时必须维护 Roo 内置待办（`update_todo_list`）。
2. 任意时刻仅允许 1 个 `in_progress` 项。
3. 存在未完成项时，不得结束当前会话任务。

## Mandatory Scope B: Program TODO.md (cross-WO)
1. Orchestrator 在项目启动阶段必须维护 `.roo_process/work_orders/PROGRAM-<date>/TODO.md`。
2. PROGRAM TODO 至少包含：里程碑、映射 WO、状态、阻塞项、下一步责任人。
3. 单个 WO 完成后只能更新对应里程碑，不得宣布 PROGRAM 完成。

## Minimum Todo Fields
1. Step name
2. Owner mode
3. Status (`pending` / `in_progress` / `completed`)

## Completion Rule
1. WO 完成：关键 gate（validate-delivery + reviewer verdict）通过后，WO 对应项才允许 `completed`。
2. Program 完成：PROGRAM TODO 全部里程碑 `completed` 且无未关闭 WO，才允许声明“任务完成”。
