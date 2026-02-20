#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <WO_ID>" >&2
  exit 2
fi

WO="$1"
TESTS=".roo_process/evidence/${WO}/tests.txt"
LOG_ROOT=".roo_process/quality/${WO}/logs/qa-skill"
COMMANDS_MD=".roo_process/quality/${WO}/commands.md"

if [[ ! -f "$TESTS" ]]; then
  echo "Missing tests file: $TESTS" >&2
  exit 2
fi

mkdir -p "$LOG_ROOT"
mkdir -p "$(dirname "$COMMANDS_MD")"
: > "$COMMANDS_MD"

idx=0
while IFS= read -r line || [[ -n "$line" ]]; do
  cmd="${line## }"
  cmd="${cmd%% }"
  [[ -z "$cmd" ]] && continue
  [[ "$cmd" == \#* ]] && continue
  ((idx+=1))
  log_file="$LOG_ROOT/test_$(printf '%02d' "$idx").log"
  {
    echo "$ $cmd"
    bash -lc "$cmd"
  } &> "$log_file" || {
    echo "- FAIL: $cmd (log: $log_file)" >> "$COMMANDS_MD"
    continue
  }
  echo "- PASS: $cmd (log: $log_file)" >> "$COMMANDS_MD"
done < "$TESTS"

echo "Executed ${idx} command(s) from $TESTS"
