# Chat-Only Execution

1. 用户通过 Roo 对话提供目标与反馈，不承担脚本执行。
2. Orchestrator 必须自行调用 `.roo_process/scripts/` 下的流程脚本。
3. 除非用户明确要求手动命令，不得把标准流程命令作为“用户待办”抛回给用户。
4. 汇报时提供结果、证据路径、失败原因与修复动作，而不是仅给命令清单。
5. 跨边界交接必须使用 Boomerang 子任务（`new_task`）分发：总包下发施工、总包转交监理。
6. 施工子任务默认从 Librarian 起步，同一 WO 内必须按 `Librarian -> Code -> Librarian` 的 `switch_mode` 链路执行，并在 Librarian 阶段完成 `_llmdoc` pre/post 同步。
7. 总包在多步骤编排中必须维护 Roo 内置待办清单（`update_todo_list`）。
8. 若边界交接所需 `new_task` 不可用，必须先报告阻断原因并获得用户确认，才能临时 fallback。
