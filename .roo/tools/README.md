# Roo Custom Tools (v3)

This directory contains JavaScript custom tools for Roo.

## Tools
- `wo_kickoff.js`: `kickoff-lean` workflow entrypoint
- `wo_context.js`: context generation (`changed` / `all`)
- `wo_delivery.js`: delivery pack and validation (`pack` / `validate`)
- `wo_review.js`: reviewer scaffold preparation
- `review_gate.js`: acceptance gate execution
  - 默认冻结检查目录为 `_SPECs`，可用 `specPaths` 覆盖。
- `wo_docs.js`: _llmdoc bridge (`init-doc` / `update-doc`)
  - Used by Librarian as a mandatory step before Code handoff and after Code completion.

## Security Model
1. Commands are constructed via allowlisted templates only.
2. Shell operators and command chaining are rejected.
3. Tool arguments are validated before command execution.

## CLI Input Note
These tool files accept exactly one JSON argument. They are not argparse-style CLIs.
Use:
- `node .roo/tools/wo_kickoff.js '{"wo":"WO-20260220-001","slug":"demo"}'`
Do not use:
- `node .roo/tools/wo_kickoff.js --help`

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
node .roo/tools/wo_docs.js '{"action":"init-doc"}'
node .roo/tools/wo_docs.js '{"action":"update-doc","wo":"WO-20260220-001"}'
```
