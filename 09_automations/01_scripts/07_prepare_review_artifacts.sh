#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX <branch-name>"
  echo "Example: $0 WO-20260207-001 wo/WO-20260207-001-add-git-policy"
  exit 1
fi

WO="$1"
BRANCH="$2"
OUT="07_delivery_packs/${WO}/99_artifacts"
mkdir -p "${OUT}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository"
  exit 2
fi

if ! git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  echo "Branch not found: ${BRANCH}"
  exit 3
fi

if ! git show-ref --verify --quiet refs/heads/main; then
  echo "Branch 'main' not found"
  exit 3
fi

git diff main..."${BRANCH}" > "${OUT}/changes.diff"
git format-patch main.."${BRANCH}" --stdout > "${OUT}/changes.patch"

echo "Prepared reviewer artifacts: ${OUT}/changes.diff, ${OUT}/changes.patch"
