#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository"
  exit 1
fi

HOOKS_DIR="$(git rev-parse --git-path hooks)"
cp .roo_template/09_automations/02_git_hooks/commit-msg "${HOOKS_DIR}/commit-msg"
cp .roo_template/09_automations/02_git_hooks/pre-push "${HOOKS_DIR}/pre-push"
chmod +x "${HOOKS_DIR}/commit-msg" "${HOOKS_DIR}/pre-push"

echo "Installed hooks to ${HOOKS_DIR}"
