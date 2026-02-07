#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX <slug>"
  echo "Example: $0 WO-20260207-001 add-git-policy"
  exit 1
fi

WO="$1"
SLUG="$2"
BRANCH="wo/${WO}-${SLUG}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository"
  exit 2
fi

bash 09_automations/01_scripts/06_git_control_check.sh "${WO}" merge

if ! git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  echo "Branch not found: ${BRANCH}"
  exit 3
fi

if ! git show-ref --verify --quiet refs/heads/main; then
  echo "Branch 'main' not found"
  exit 3
fi

git switch main >/dev/null
git merge --no-ff "${BRANCH}" -m "Merge ${WO}"

echo "Merged ${BRANCH} into main"
