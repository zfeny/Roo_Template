# Chat-Only Execution

1. 用户通过 Roo 对话提供目标与反馈，不承担脚本执行。
2. Orchestrator 必须自行调用 `.roo_template/09_automations/01_scripts/` 下的流程脚本。
3. 除非用户明确要求手动命令，不得把标准流程命令作为“用户待办”抛回给用户。
4. 汇报时提供结果、证据路径、失败原因与修复动作，而不是仅给命令清单。
