# A/B Validation Playbook (v3 Extension)

## Objective
对比旧流程历史样本与 Skills v2/v3 流程样本，量化效率与验收质量变化。

## Required Samples
1. Baseline: 旧流程历史 WO ×1（来自历史记录）。
2. Skills v2: 新流程 WO ×1（按 `wo_flow.py` 执行）。
3. Skills v3: 工具化流程 WO ×1（按 `.roo/tools/*.js` 执行）。

## Metrics
1. 首提交时延（kickoff 到 first implementation commit）
2. 跨边界子任务交接次数（`new_task`，WO 生命周期）
3. 同一 WO 施工内模式切换次数（`switch_mode`）
4. Reviewer 首轮通过率
5. 平均补证据次数
6. 工具调用失败率（tool fail / total tool calls）
7. 工具回退率（fallback to script / total tool calls）

## Data Template
| WO | Flow Type | First Commit Latency | boundary new_task Count | intra-WO switch_mode Count | First Review Verdict | Evidence Rework Count |
|---|---|---|---|---|---|---|
| WO-YYYYMMDD-001 | baseline/v2 |  |  |  |  |  |

## v3 Tooling Metrics Template
| WO | Flow Type | Tool Calls | Tool Failures | Tool Failure Rate | Script Fallback Count | Script Fallback Rate |
|---|---|---|---|---|---|---|
| WO-YYYYMMDD-001 | v3 |  |  |  |  |  |

## Current Dry-Run Snapshot
- WO: `WO-20260209-001`
- `kickoff-lean`: PASS（branch issuance verified）
- `prepare-context`: PASS
- `pack-delivery`: PASS
- `prepare-review`: PASS
- `validate-delivery`: PASS
- `review_gate.py` positive sample: PASS
- `review_gate.py` negative sample (`WO-20260220-999`): FAIL as expected

## Exit Criteria
1. 首提交时延下降 >= 30%
2. `new_task` 覆盖跨边界交接（总包->施工、总包->监理）
3. 同一 WO 施工内角色切换主要通过 `switch_mode` 完成（无不必要新增子任务）
4. Reviewer 首轮 PASS 率提升 >= 20%
5. 无 `.roo_template` 非归档引用
6. v3 工具调用失败率 < 5%
