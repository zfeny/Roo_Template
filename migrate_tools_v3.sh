#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Migrate Roo custom tools v3 into the current repository.

Usage:
  migrate_tools_v3.sh [--source <template-root>] [--dry-run] [--force] [--no-backup]

Options:
  --source <path>   Template root containing .roo/tools (default: script-relative root)
  --dry-run         Print plan only, do not write files
  --force           Overwrite existing .roo/tools without confirmation
  --no-backup       Do not backup existing .roo/tools
  -h, --help        Show this help
USAGE
}

SOURCE_ROOT=""
DRY_RUN="0"
FORCE="0"
BACKUP="1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      SOURCE_ROOT="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="1"
      shift
      ;;
    --force)
      FORCE="1"
      shift
      ;;
    --no-backup)
      BACKUP="0"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

ROOT="$(pwd)"
if [[ -z "$SOURCE_ROOT" ]]; then
  SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

SOURCE_TOOLS="$SOURCE_ROOT/.roo/tools"
TARGET_TOOLS="$ROOT/.roo/tools"
ROOMODES="$ROOT/.roomodes"
REPORT="$ROOT/migration_report_tools_v3.md"

if [[ ! -d "$SOURCE_TOOLS" ]]; then
  echo "Source tools directory not found: $SOURCE_TOOLS" >&2
  exit 2
fi
if [[ ! -f "$ROOMODES" ]]; then
  echo "Missing .roomodes in target repo: $ROOT" >&2
  exit 2
fi

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$ROOT/archive/migrations/$TIMESTAMP/tools_backup"

update_roomodes() {
  local file="$1"
  local tmp
  tmp="$(mktemp)"
  cp "$file" "$tmp"

  if ! grep -F "Prefer custom tool '.roo/tools/wo_kickoff.js'" "$tmp" >/dev/null 2>&1; then
    perl -0pi -e "s#Prefer skill `\\.roo/skills/orchestrator/wo-dispatch-contract/` when issuing a new WO and\n      `\\.roo/skills/orchestrator/wo-queue-dispatch/` for queue-governed low-risk dispatch\\.#Prefer custom tool '.roo/tools/wo_kickoff.js' first, then '.roo/tools/wo_context.js', '.roo/tools/wo_delivery.js', and '.roo/tools/wo_review.js'; fallback to wo_flow.py commands when a tool is unavailable.\n      Prefer skill `\\.roo/skills/orchestrator/wo-dispatch-contract/` when issuing a new WO and\n      `\\.roo/skills/orchestrator/wo-queue-dispatch/` for queue-governed low-risk dispatch.#s" "$tmp"
  fi

  if ! grep -F "Prefer custom tool '.roo/tools/wo_delivery.js'" "$tmp" >/dev/null 2>&1; then
    perl -0pi -e "s#Prefer skill `\\.roo/skills/code/wo-lean-build/` for standard WO execution\\.#Prefer custom tool '.roo/tools/wo_delivery.js' first for pack\/validate, then '.roo/tools/wo_context.js' for context refresh; fallback to wo_flow.py commands when tools fail.\n      Prefer skill `\\.roo/skills/code/wo-lean-build/` for standard WO execution.#s" "$tmp"
  fi

  if ! grep -F "Prefer custom tool '.roo/tools/review_gate.js'" "$tmp" >/dev/null 2>&1; then
    perl -0pi -e "s#Prefer skill `\\.roo/skills/reviewer/wo-independent-acceptance/` for final verdicts\\.#Prefer custom tool '.roo/tools/review_gate.js' first and '.roo/tools/wo_review.js' for scaffold preparation; fallback to review_gate.py\/wo_flow.py when tools fail.\n      Prefer skill `\\.roo/skills/reviewer/wo-independent-acceptance/` for final verdicts.#s" "$tmp"
  fi

  cat "$tmp" > "$file"
  rm -f "$tmp"
}

print_plan() {
  echo "[plan] source tools: $SOURCE_TOOLS"
  echo "[plan] target tools: $TARGET_TOOLS"
  echo "[plan] roomodes: $ROOMODES"
  echo "[plan] report: $REPORT"
  if [[ -d "$TARGET_TOOLS" && "$BACKUP" == "1" ]]; then
    echo "[plan] backup existing tools -> $BACKUP_DIR"
  fi
}

print_plan
if [[ "$DRY_RUN" == "1" ]]; then
  echo "[dry-run] no files changed"
  exit 0
fi

if [[ -d "$TARGET_TOOLS" && "$FORCE" != "1" ]]; then
  echo "Target already has .roo/tools. Re-run with --force to overwrite." >&2
  exit 3
fi

mkdir -p "$(dirname "$REPORT")"

same_source_and_target="0"
if [[ -d "$TARGET_TOOLS" ]]; then
  src_real="$(cd "$SOURCE_TOOLS" && pwd)"
  dst_real="$(cd "$TARGET_TOOLS" && pwd)"
  if [[ "$src_real" == "$dst_real" ]]; then
    same_source_and_target="1"
  fi
fi

if [[ "$same_source_and_target" == "0" && -d "$TARGET_TOOLS" && "$BACKUP" == "1" ]]; then
  mkdir -p "$BACKUP_DIR"
  cp -R "$TARGET_TOOLS"/. "$BACKUP_DIR"/
fi

if [[ "$same_source_and_target" == "0" ]]; then
  rm -rf "$TARGET_TOOLS"
  mkdir -p "$TARGET_TOOLS"
  cp -R "$SOURCE_TOOLS"/. "$TARGET_TOOLS"/
fi

update_roomodes "$ROOMODES"

cat > "$REPORT" <<REPORT
# Tools v3 Migration Report

- Timestamp: $TIMESTAMP
- Source: $SOURCE_TOOLS
- Target: $TARGET_TOOLS
- Dry Run: $DRY_RUN
- Forced: $FORCE
- Backup Enabled: $BACKUP
- Backup Path: ${BACKUP_DIR:-N/A}
- Source equals target: $same_source_and_target

## Result
- .roo/tools installed or updated (or skipped copy when source equals target)
- .roomodes customInstructions patched for tool-first fallback strategy
- src/ untouched
- _SPECs untouched
REPORT

echo "Migration completed: $REPORT"
