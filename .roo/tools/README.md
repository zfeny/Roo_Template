# Roo Custom Tools (v3)

This directory contains JavaScript custom tools for Roo.

## Tools
- `wo_kickoff.js`: `kickoff-lean` workflow entrypoint
- `wo_context.js`: context generation (`changed` / `all`)
- `wo_delivery.js`: delivery pack and validation (`pack` / `validate`)
- `wo_review.js`: reviewer scaffold preparation
- `review_gate.js`: acceptance gate execution

## Security Model
1. Commands are constructed via allowlisted templates only.
2. Shell operators and command chaining are rejected.
3. Tool arguments are validated before command execution.

## JSON Output Contract
Each tool returns:
- `status`: `ok` or `fail`
- `tool`: tool identifier
- `command`: executed command
- `stdout` / `stderr`
- `artifacts`: related process paths
- `warnings`: policy warnings (Todo/Worktree)

## Local Smoke Examples
```bash
node .roo/tools/wo_kickoff.js '{"wo":"WO-20260220-001","slug":"demo"}'
node .roo/tools/wo_context.js '{"wo":"WO-20260220-001","mode":"changed"}'
node .roo/tools/wo_delivery.js '{"wo":"WO-20260220-001","action":"pack"}'
node .roo/tools/wo_review.js '{"wo":"WO-20260220-001","action":"prepare-review"}'
node .roo/tools/review_gate.js '{"wo":"WO-20260220-001","strict":true}'
```
