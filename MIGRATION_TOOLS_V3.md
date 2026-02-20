# Migration Guide: Tools v3

## Purpose
Upgrade existing repositories from Skills v2 script-first usage to v3 tool-first usage.

## Script
- `./migrate_tools_v3.sh`

## Default Safety
1. Back up existing `.roo/tools` (if present).
2. Install or update `.roo/tools/*` from template source.
3. Patch `.roomodes` with tool-first + script-fallback guidance.
4. Generate migration report: `./migration_report_tools_v3.md`.
5. Do not modify `src/` or `_SPECs/`.

## Options
```bash
bash ./migrate_tools_v3.sh --dry-run
bash ./migrate_tools_v3.sh --force
bash ./migrate_tools_v3.sh --force --no-backup
bash ./migrate_tools_v3.sh --source /path/to/Roo_Template --force
```

## Rollout Steps
1. Run `--dry-run` and review plan output.
2. Run with `--force` for actual migration.
3. Verify `.roo/tools` exists and `.roomodes` contains tool-first instructions.
4. Run a WO smoke path using tools (`wo_kickoff` -> `wo_context` -> `wo_delivery` -> `review_gate`).
