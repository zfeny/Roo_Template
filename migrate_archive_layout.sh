#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Migrate legacy archive assets out of process scope into a root archive directory.

Usage:
  migrate_archive_layout.sh [--archive-root <path>] [--source <path>] [--dry-run]

Options:
  --archive-root <path>  Target archive root (default: archive)
  --source <path>        Source archive path (default: legacy process archive path)
  --dry-run              Print planned actions without modifying files
  -h, --help             Show this help
USAGE
}

ARCHIVE_ROOT="archive"
PROCESS_ROOT=".roo_process"
SOURCE_PATH="$PROCESS_ROOT/archive"
DRY_RUN="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive-root)
      ARCHIVE_ROOT="${2:-}"
      shift 2
      ;;
    --source)
      SOURCE_PATH="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="1"
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
SOURCE="$ROOT/$SOURCE_PATH"
ARCHIVE="$ROOT/$ARCHIVE_ROOT"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
MIGRATION_DIR="$ARCHIVE/migrations/$TIMESTAMP"
CONFLICT_DIR="$MIGRATION_DIR/conflicts"
REPORT="$MIGRATION_DIR/archive_migration_report.md"

if [[ ! -d "$SOURCE" ]]; then
  echo "No source archive found at: $SOURCE"
  exit 0
fi

if [[ "$SOURCE" == "$ARCHIVE" ]]; then
  echo "Source and archive root are identical; nothing to do."
  exit 0
fi

if [[ "$ARCHIVE" == "$SOURCE/"* ]]; then
  echo "archive-root cannot be inside source path: $ARCHIVE_ROOT" >&2
  exit 1
fi

planned_moves=0
planned_conflicts=0

while IFS= read -r -d '' entry; do
  rel="${entry#$SOURCE/}"
  dst="$ARCHIVE/$rel"
  ((planned_moves+=1))
  if [[ -e "$dst" ]]; then
    ((planned_conflicts+=1))
  fi
done < <(find "$SOURCE" -mindepth 1 -type f -print0)

echo "[plan] source: $SOURCE_PATH"
echo "[plan] archive-root: $ARCHIVE_ROOT"
echo "[plan] files: $planned_moves"
echo "[plan] potential-conflicts: $planned_conflicts"
echo "[plan] report: $ARCHIVE_ROOT/migrations/$TIMESTAMP/archive_migration_report.md"

if [[ "$DRY_RUN" == "1" ]]; then
  echo "[dry-run] no files changed"
  exit 0
fi

mkdir -p "$ARCHIVE" "$MIGRATION_DIR"

moved_count=0
conflict_count=0

while IFS= read -r -d '' entry; do
  rel="${entry#$SOURCE/}"
  dst="$ARCHIVE/$rel"

  if [[ -e "$dst" ]]; then
    mkdir -p "$CONFLICT_DIR/$(dirname "$rel")"
    mv "$entry" "$CONFLICT_DIR/$rel"
    ((conflict_count+=1))
  else
    mkdir -p "$(dirname "$dst")"
    mv "$entry" "$dst"
    ((moved_count+=1))
  fi
done < <(find "$SOURCE" -mindepth 1 -type f -print0)

# Move empty directories to preserve layout when possible.
while IFS= read -r -d '' dir; do
  rel="${dir#$SOURCE/}"
  dst="$ARCHIVE/$rel"
  if [[ ! -e "$dst" ]]; then
    mkdir -p "$dst"
  fi
done < <(find "$SOURCE" -mindepth 1 -type d -empty -print0)

rm -rf "$SOURCE"

cat > "$REPORT" <<REPORT
# Archive Layout Migration Report

- Timestamp: $TIMESTAMP
- Source: $SOURCE_PATH
- Target archive root: $ARCHIVE_ROOT
- Moved files: $moved_count
- Conflict files moved to: ${ARCHIVE_ROOT}/migrations/$TIMESTAMP/conflicts
- Conflict count: $conflict_count

## Result
- legacy process archive directory removed
- archive assets relocated under $ARCHIVE_ROOT/
- On conflicts, existing target files were kept and source files were moved to conflicts/
REPORT

echo "Archive migration completed: $REPORT"
