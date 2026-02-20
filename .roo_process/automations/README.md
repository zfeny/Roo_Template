# Automations (Agent-Triggered)

本目录只保留对话内触发的自动化定义，不要求用户手动执行终端命令。

## Engines
- `../scripts/wo_flow.py`: WO 生命周期脚手架（kickoff/context/delivery/review/validate）。
- `../scripts/review_gate.py`: 验收 Gate 引擎（证据、AC、tests、CR、SPEC 冻结）。

## Trigger Source
- 通过 Roo 对话中的 mode 切换或显式流程请求触发。
- 触发定义见 `triggers.yaml`。

legacy Bash / hook / make 资产已迁入：
- `.roo_process/archive/legacy_automations_snapshot/`
