#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX"
  exit 1
fi

WO="$1"
BASE=".roo_process/review_reports/${WO}"
mkdir -p "${BASE}"

if [[ ! -f "${BASE}/Review.md" ]]; then
  cat > "${BASE}/Review.md" << 'EOT'
# Review

Verdict: PASS | FAIL

## Blocking Findings

## Non-blocking Findings

## Evidence Checked

## Decision Rationale
EOT
fi

if [[ ! -f "${BASE}/02_Blockers.md" ]]; then
  cat > "${BASE}/02_Blockers.md" << 'EOT'
# Blockers

- None
EOT
fi

if [[ ! -f "${BASE}/03_FollowUps.md" ]]; then
  cat > "${BASE}/03_FollowUps.md" << 'EOT'
# Follow-ups

- None
EOT
fi

echo "Prepared review report scaffold for ${WO}: ${BASE}"
