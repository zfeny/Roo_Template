# Todo Policy

## Objective
保证长链路任务在执行前就具备显式步骤、顺序和完成状态。

## Mandatory Scope
1. Orchestrator 与 Debug 模式下，任务步骤 >= 4 时必须维护 Todo 列表。
2. 未建立 Todo 时，不进入执行阶段。

## Minimum Todo Fields
1. Step name
2. Owner mode
3. Status (`pending` / `in_progress` / `completed`)

## Completion Rule
1. 只有当关键 gate（validate-delivery + reviewer verdict）完成后，WO Todo 才允许全部标记 completed。
