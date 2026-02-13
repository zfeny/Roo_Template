#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository"
  exit 1
fi

HOOKS_DIR="$(git rev-parse --git-path hooks)"
cp .roo_process/automations/git_hooks/commit-msg "${HOOKS_DIR}/commit-msg"
cp .roo_process/automations/git_hooks/pre-push "${HOOKS_DIR}/pre-push"
chmod +x "${HOOKS_DIR}/commit-msg" "${HOOKS_DIR}/pre-push"

echo "Installed hooks to ${HOOKS_DIR}"
