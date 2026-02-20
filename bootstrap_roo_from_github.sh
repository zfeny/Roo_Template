#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Bootstrap Roo workflow assets from a GitHub repository.

Usage:
  bootstrap_roo_from_github.sh [--repo <owner/repo|github-url>] [--ref <branch_or_tag_or_sha>] [--dest <path>] [--hot-update] [--include-specs] [--include-archive] [--archive-root <path>] [--force] [--cleanup-legacy|--no-cleanup-legacy]

Options:
  --repo            GitHub repository (owner/repo, git@github.com:owner/repo.git, or https://github.com/owner/repo.git)
                    default: zfeny/Roo_Template (or $ROO_BOOTSTRAP_DEFAULT_REPO)
  --ref             Branch/tag/commit-ish used for tarball download (default: main)
  --dest            Target project directory (default: current directory)
  --hot-update      Update runtime engine files only (preserve existing WO/context/quality/evidence/review assets)
  --include-specs   Also sync _SPECs directory from template repo
  --include-archive Also sync archive directory from template repo
  --archive-root    Target archive root path (default: archive)
  --force           Overwrite existing .roo/.roomodes/.roo_process in target
  --cleanup-legacy  Remove legacy Roo process directories after sync (default: on)
  --no-cleanup-legacy
                    Keep legacy Roo process directories
  GITHUB_TOKEN      Optional token for private repositories
  -h, --help        Show this help
EOF
}

REPO=""
REF="main"
DEST="."
INCLUDE_SPECS="0"
INCLUDE_ARCHIVE="0"
HOT_UPDATE="0"
FORCE="0"
DEFAULT_REPO="${ROO_BOOTSTRAP_DEFAULT_REPO:-zfeny/Roo_Template}"
CLEANUP_LEGACY="1"
ARCHIVE_ROOT="archive"
HOT_PROCESS_SUBDIRS=("scripts" "automations" "templates" "docs")

normalize_repo() {
  local raw="$1"
  local out=""

  case "$raw" in
    git@github.com:*)
      out="${raw#git@github.com:}"
      ;;
    ssh://git@github.com/*)
      out="${raw#ssh://git@github.com/}"
      ;;
    https://github.com/*)
      out="${raw#https://github.com/}"
      ;;
    http://github.com/*)
      out="${raw#http://github.com/}"
      ;;
    github.com/*)
      out="${raw#github.com/}"
      ;;
    *)
      out="$raw"
      ;;
  esac

  out="${out%.git}"
  out="${out#/}"
  out="${out%/}"

  if [[ ! "$out" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]]; then
    echo "Invalid --repo format: $raw" >&2
    echo "Expected owner/repo, git@github.com:owner/repo.git, or https://github.com/owner/repo.git" >&2
    exit 1
  fi

  printf '%s' "$out"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --ref)
      REF="${2:-}"
      shift 2
      ;;
    --dest)
      DEST="${2:-}"
      shift 2
      ;;
    --include-specs)
      INCLUDE_SPECS="1"
      shift
      ;;
    --hot-update)
      HOT_UPDATE="1"
      shift
      ;;
    --include-archive)
      INCLUDE_ARCHIVE="1"
      shift
      ;;
    --archive-root)
      ARCHIVE_ROOT="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="1"
      shift
      ;;
    --cleanup-legacy)
      CLEANUP_LEGACY="1"
      shift
      ;;
    --no-cleanup-legacy)
      CLEANUP_LEGACY="0"
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

if [[ -z "$ARCHIVE_ROOT" ]]; then
  echo "--archive-root cannot be empty" >&2
  exit 1
fi

if [[ "$HOT_UPDATE" == "1" && "$FORCE" == "1" ]]; then
  echo "WARN: --force is ignored in --hot-update mode"
  FORCE="0"
fi

if [[ -z "$REPO" ]]; then
  REPO="$DEFAULT_REPO"
  echo "Using default template repository: $REPO"
fi

REPO="$(normalize_repo "$REPO")"

if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required" >&2
  exit 1
fi

if command -v curl >/dev/null 2>&1; then
  FETCHER="curl"
elif command -v wget >/dev/null 2>&1; then
  FETCHER="wget"
else
  echo "Either curl or wget is required" >&2
  exit 1
fi

mkdir -p "$DEST"
DEST_ABS="$(cd "$DEST" && pwd)"

if [[ "$HOT_UPDATE" != "1" ]]; then
  for p in .roo .roomodes .roo_process; do
    if [[ -e "$DEST_ABS/$p" && "$FORCE" != "1" ]]; then
      echo "Target already has $p. Re-run with --force to overwrite." >&2
      exit 2
    fi
  done
fi

if [[ "$INCLUDE_ARCHIVE" == "1" && -e "$DEST_ABS/$ARCHIVE_ROOT" && "$FORCE" != "1" ]]; then
  echo "Target already has $ARCHIVE_ROOT. Re-run with --force to overwrite." >&2
  exit 2
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARBALL="$TMP_DIR/repo.tar.gz"
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  URL="https://api.github.com/repos/${REPO}/tarball/${REF}"
else
  URL="https://codeload.github.com/${REPO}/tar.gz/${REF}"
fi

if [[ "$FETCHER" == "curl" ]]; then
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    curl -fsSL \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      "$URL" -o "$TARBALL"
  else
    curl -fsSL "$URL" -o "$TARBALL"
  fi
else
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    wget -q \
      --header="Authorization: Bearer ${GITHUB_TOKEN}" \
      --header="Accept: application/vnd.github+json" \
      "$URL" -O "$TARBALL"
  else
    wget -q "$URL" -O "$TARBALL"
  fi
fi

if [[ ! -s "$TARBALL" ]]; then
  echo "Failed to download repository tarball from: $URL" >&2
  echo "Hints:" >&2
  echo "  1) Use --repo as owner/repo (or a GitHub SSH/HTTPS URL)." >&2
  echo "  2) Verify --ref exists (branch/tag/commit)." >&2
  echo "  3) For private repos, export GITHUB_TOKEN first." >&2
  exit 3
fi

tar -xzf "$TARBALL" -C "$TMP_DIR"
SRC_ROOT="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [[ -z "$SRC_ROOT" ]]; then
  echo "Failed to unpack repository tarball from $URL" >&2
  exit 3
fi

copy_item() {
  local src="$1"
  local dst="$2"
  rm -rf "$dst"
  if [[ -d "$src" ]]; then
    cp -R "$src" "$dst"
  else
    cp "$src" "$dst"
  fi
}

rescue_process_archive() {
  local root="$1"
  local archive_root="$2"
  local process_root="$root/.roo_process"
  local source="$process_root/archive"
  local target="$root/$archive_root"
  local timestamp
  local migration_dir
  local conflict_dir
  local report
  local moved_count=0
  local conflict_count=0

  if [[ ! -d "$source" ]]; then
    return
  fi

  timestamp="$(date +%Y%m%d-%H%M%S)"
  migration_dir="$target/migrations/$timestamp"
  conflict_dir="$migration_dir/conflicts_from_bootstrap"
  report="$migration_dir/bootstrap_archive_rescue_report.md"

  mkdir -p "$target" "$migration_dir"

  while IFS= read -r -d '' entry; do
    rel="${entry#$source/}"
    dst="$target/$rel"

    if [[ -e "$dst" ]]; then
      mkdir -p "$conflict_dir/$(dirname "$rel")"
      mv "$entry" "$conflict_dir/$rel"
      ((conflict_count+=1))
    else
      mkdir -p "$(dirname "$dst")"
      mv "$entry" "$dst"
      ((moved_count+=1))
    fi
  done < <(find "$source" -mindepth 1 -type f -print0)

  while IFS= read -r -d '' dir; do
    rel="${dir#$source/}"
    dst="$target/$rel"
    if [[ ! -e "$dst" ]]; then
      mkdir -p "$dst"
    fi
  done < <(find "$source" -mindepth 1 -type d -empty -print0)

  rm -rf "$source"

  cat > "$report" <<REPORT
# Bootstrap Archive Rescue Report

- Source: legacy process archive path
- Target: $archive_root
- Moved files: $moved_count
- Conflict files: $conflict_count
- Conflict directory: ${archive_root}/migrations/$timestamp/conflicts_from_bootstrap
REPORT

  echo "Rescued legacy process archive to $archive_root (moved=$moved_count conflicts=$conflict_count)"
}

cleanup_legacy_dirs() {
  local root="$1"
  local removed=()
  local legacy_dirs=(
    ".roo_template"
    "01_spec_locked"
    "02_templates"
    "03_work_orders"
    "04_context_packs"
    "05_src"
    "06_quality"
    "07_delivery_packs"
    "08_review_reports"
    "09_automations"
    "10_docs"
  )

  for d in "${legacy_dirs[@]}"; do
    if [[ -e "$root/$d" ]]; then
      rm -rf "$root/$d"
      removed+=("$d")
    fi
  done

  if [[ ${#removed[@]} -gt 0 ]]; then
    echo "Removed legacy Roo directories:"
    for d in "${removed[@]}"; do
      echo "  - $d"
    done
  fi
}

if [[ "$FORCE" == "1" ]]; then
  rescue_process_archive "$DEST_ABS" "$ARCHIVE_ROOT"
fi

for p in .roo .roomodes .roo_process; do
  if [[ ! -e "$SRC_ROOT/$p" ]]; then
    echo "Template missing required path: $p" >&2
    exit 4
  fi
done

if [[ "$HOT_UPDATE" == "1" ]]; then
  copy_item "$SRC_ROOT/.roo" "$DEST_ABS/.roo"
  copy_item "$SRC_ROOT/.roomodes" "$DEST_ABS/.roomodes"
  mkdir -p "$DEST_ABS/.roo_process"
  for sub in "${HOT_PROCESS_SUBDIRS[@]}"; do
    if [[ -e "$SRC_ROOT/.roo_process/$sub" ]]; then
      copy_item "$SRC_ROOT/.roo_process/$sub" "$DEST_ABS/.roo_process/$sub"
    fi
  done
else
  for p in .roo .roomodes .roo_process; do
    copy_item "$SRC_ROOT/$p" "$DEST_ABS/$p"
  done
fi

if [[ "$INCLUDE_ARCHIVE" == "1" ]]; then
  if [[ -d "$SRC_ROOT/archive" ]]; then
    copy_item "$SRC_ROOT/archive" "$DEST_ABS/$ARCHIVE_ROOT"
  else
    mkdir -p "$DEST_ABS/$ARCHIVE_ROOT"
  fi
fi

if [[ "$INCLUDE_SPECS" == "1" ]]; then
  if [[ -d "$SRC_ROOT/_SPECs" ]]; then
    copy_item "$SRC_ROOT/_SPECs" "$DEST_ABS/_SPECs"
  else
    mkdir -p "$DEST_ABS/_SPECs"
  fi
else
  mkdir -p "$DEST_ABS/_SPECs"
fi

mkdir -p "$DEST_ABS/src"

if [[ "$CLEANUP_LEGACY" == "1" ]]; then
  cleanup_legacy_dirs "$DEST_ABS"
fi

echo "Roo bootstrap completed: $DEST_ABS"
if [[ "$HOT_UPDATE" == "1" ]]; then
  echo "Hot update applied: .roo, .roomodes, .roo_process/{scripts,automations,templates,docs}"
  echo "Preserved: .roo_process/{work_orders,context_packs,quality,evidence,review_reports,changes}"
else
  echo "Installed: .roo, .roomodes, .roo_process"
fi
if [[ "$INCLUDE_ARCHIVE" == "1" ]]; then
  echo "Archive synced: $ARCHIVE_ROOT"
else
  echo "Archive untouched by default"
fi
if [[ "$INCLUDE_SPECS" == "1" ]]; then
  echo "_SPECs synced from template"
else
  echo "_SPECs created as empty placeholder"
fi
