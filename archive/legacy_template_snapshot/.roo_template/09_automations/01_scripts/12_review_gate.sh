#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 0 && "$1" != --* ]]; then
  FEATURE="$1"
  shift
  exec python3 scripts/review_gate.py --feature "${FEATURE}" "$@"
fi

exec python3 scripts/review_gate.py "$@"
