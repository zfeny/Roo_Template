#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Bootstrap Roo workflow assets from a GitHub repository.

Usage:
  bootstrap_roo_from_github.sh --repo <owner/repo> [--ref <branch_or_tag>] [--dest <path>] [--include-specs] [--force]

Options:
  --repo            GitHub repository in owner/repo form (required)
  --ref             Branch/tag/commit-ish used for tarball download (default: main)
  --dest            Target project directory (default: current directory)
  --include-specs   Also sync _SPECs directory from template repo
  --force           Overwrite existing .roo/.roomodes/.roo_process in target
  -h, --help        Show this help
EOF
}

REPO=""
REF="main"
DEST="."
INCLUDE_SPECS="0"
FORCE="0"

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
    --force)
      FORCE="1"
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

if [[ -z "$REPO" ]]; then
  echo "--repo is required" >&2
  usage
  exit 1
fi

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

for p in .roo .roomodes .roo_process; do
  if [[ -e "$DEST_ABS/$p" && "$FORCE" != "1" ]]; then
    echo "Target already has $p. Re-run with --force to overwrite." >&2
    exit 2
  fi
done

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARBALL="$TMP_DIR/repo.tar.gz"
URL="https://codeload.github.com/${REPO}/tar.gz/refs/heads/${REF}"

if [[ "$FETCHER" == "curl" ]]; then
  curl -fsSL "$URL" -o "$TARBALL"
else
  wget -q "$URL" -O "$TARBALL"
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

for p in .roo .roomodes .roo_process; do
  if [[ ! -e "$SRC_ROOT/$p" ]]; then
    echo "Template missing required path: $p" >&2
    exit 4
  fi
  copy_item "$SRC_ROOT/$p" "$DEST_ABS/$p"
done

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

echo "Roo bootstrap completed: $DEST_ABS"
echo "Installed: .roo, .roomodes, .roo_process"
if [[ "$INCLUDE_SPECS" == "1" ]]; then
  echo "_SPECs synced from template"
else
  echo "_SPECs created as empty placeholder"
fi
