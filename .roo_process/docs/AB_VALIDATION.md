# A/B Validation Playbook (v3 Extension)

## Objective
对比旧流程历史样本与 Skills v2/v3 流程样本，量化效率与验收质量变化。

## Required Samples
1. Baseline: 旧流程历史 WO ×1（来自历史记录）。
2. Skills v2: 新流程 WO ×1（按 `wo_flow.py` 执行）。
3. Skills v3: 工具化流程 WO ×1（按 `.roo/tools/*.js` 执行）。

## Metrics
1. 首提交时延（kickoff 到 first implementation commit）
2. 模式切换次数（WO 生命周期）
3. Reviewer 首轮通过率
4. 平均补证据次数
5. 工具调用失败率（tool fail / total tool calls）
6. 工具回退率（fallback to script / total tool calls）

## Data Template
| WO | Flow Type | First Commit Latency | Mode Switch Count | First Review Verdict | Evidence Rework Count |
|---|---|---|---|---|---|
| WO-YYYYMMDD-001 | baseline/v2 |  |  |  |  |

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
2. 模式切换数下降 >= 30%
3. Reviewer 首轮 PASS 率提升 >= 20%
4. 无 `.roo_template` 非归档引用
5. v3 工具调用失败率 < 5%
