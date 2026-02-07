# General Rules

## 1) 目标
建立可追溯、可审计、可复核的工序化交付流程。

## 2) 全局硬约束
1. 所有实施类工作必须绑定唯一 WO（`WO-YYYYMMDD-XXX`）。
2. 未建立 `03_work_orders/{WO}` 与 `04_context_packs/{WO}` 前，不进入编码。
3. 未产出 `06_quality/04_reports/{WO}` 与 `07_delivery_packs/{WO}` 前，不声称完成。
4. `01_spec_locked/` 默认为只读权威，除非用户明确要求改动。

## 3) 证据优先
1. 结论必须可回指文件路径。
2. 口头说明不等于验收证据。
3. 质量结论必须包含执行命令与日志位置。
