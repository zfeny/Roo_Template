#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX <branch|commit|merge>"
  exit 1
fi

WO="$1"
MODE="$2"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository"
  exit 2
fi

branch_check() {
  local cur
  cur="$(git rev-parse --abbrev-ref HEAD)"
  if [[ ! "${cur}" =~ ^wo/${WO}-[a-z0-9._-]+$ ]]; then
    echo "Branch check failed: current '${cur}' does not match 'wo/${WO}-<slug>'"
    exit 3
  fi
  echo "Branch check passed: ${cur}"
}

commit_check() {
  local msg
  msg="$(git log -1 --pretty=%s 2>/dev/null || true)"
  if [[ -z "${msg}" ]]; then
    echo "Commit check failed: no commits found"
    exit 4
  fi
  if [[ ! "${msg}" =~ ^${WO}:\  ]]; then
    echo "Commit check failed: latest commit must start with '${WO}: '"
    echo "Latest commit: ${msg}"
    exit 4
  fi
  echo "Commit check passed: ${msg}"
}

merge_check() {
  local review=".roo_process/review_reports/${WO}/Review.md"
  local delivery=".roo_process/evidence/${WO}/DeliveryPack.md"

  if [[ ! -f "${delivery}" ]]; then
    echo "Merge check failed: missing ${delivery}"
    exit 5
  fi

  if [[ ! -f "${review}" ]]; then
    echo "Merge check failed: missing ${review}"
    exit 5
  fi

  if grep -nE '^[[:space:]]*Verdict:[[:space:]]*PASS[[:space:]]*$|^[[:space:]]*-[[:space:]]*Decision:[[:space:]]*PASS[[:space:]]*$' "${review}" >/dev/null 2>&1; then
    echo "Merge check passed: reviewer verdict PASS"
  else
    echo "Merge check failed: reviewer verdict PASS not found in ${review}"
    exit 5
  fi
}

case "${MODE}" in
  branch)
    branch_check
    ;;
  commit)
    commit_check
    ;;
  merge)
    merge_check
    ;;
  *)
    echo "Invalid mode: ${MODE}. Use branch|commit|merge"
    exit 1
    ;;
esac
