# Review Gate MVP

## Purpose

Provide reproducible acceptance checks that rely on objective evidence instead of verbal status.

## Required Structure

1. Evidence package: `evidence/<feature_or_block_id>/`
2. Required files:
- `summary.md`
- `tests.txt`
- `evidence.json` (optional, WARN if missing)
3. Change request documents when deviating from SPEC:
- `changes/CR-YYYYMMDD-xxx.md`

## summary.md contract

- Must include: `SPEC_ALIGNMENT: ALIGNED` or `SPEC_ALIGNMENT: DEVIATED`
- Optional explicit marker: `SPEC_DEVIATION: true|false`
- Must reference acceptance IDs (`AC-001` style, or IDs auto-detected from frozen SPEC files)
- If `DEVIATED`, must reference at least one CR ID (`CR-YYYYMMDD-xxx`)

## Commands

- Direct:
  - `python3 scripts/review_gate.py --feature WO-20260209-001`
- WO helper:
  - `bash .roo_template/09_automations/01_scripts/00_wo.sh review-gate WO-20260209-001`
- CI-style diff scope:
  - `python3 scripts/review_gate.py --feature WO-20260209-001 --base-ref main --head-ref HEAD`

## What review_gate checks

1. Frozen SPEC paths unchanged in current diff scope (default: `specs/` + `.roo_template/01_spec_locked` if present)
2. Evidence package exists and required files are present
3. `summary.md` includes acceptance references
4. `tests.txt` commands are executed line-by-line; any failure fails gate
5. Deviation to SPEC requires CR references and existing CR files (strict mode on by default)
6. Outputs PASS/FAIL with explicit blocking reasons
