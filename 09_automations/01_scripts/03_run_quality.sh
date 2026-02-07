#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX"
  exit 1
fi

WO="$1"
OUT_DIR="06_quality/04_reports/${WO}"
mkdir -p "${OUT_DIR}/03_logs"
CMDS="${OUT_DIR}/02_commands.md"
RPT="${OUT_DIR}/01_quality_report.md"

: > "${CMDS}"

echo "# Commands" >> "${CMDS}"
echo >> "${CMDS}"

echo "# Quality Report" > "${RPT}"
echo >> "${RPT}"

run_and_log() {
  local name="$1"
  local cmd="$2"
  echo "## ${name}" >> "${CMDS}"
  echo '```bash' >> "${CMDS}"
  echo "${cmd}" >> "${CMDS}"
  echo '```' >> "${CMDS}"
  echo >> "${CMDS}"

  if bash -lc "${cmd}" > "${OUT_DIR}/03_logs/${name}.log" 2>&1; then
    echo "- ${name}: PASS" >> "${RPT}"
  else
    echo "- ${name}: FAIL" >> "${RPT}"
  fi
}

if [[ -f "package.json" ]]; then
  run_and_log "npm-test" "npm test --silent"
fi

if command -v pytest >/dev/null 2>&1; then
  run_and_log "pytest" "pytest -q"
fi

if command -v rg >/dev/null 2>&1; then
  run_and_log "repo-scan" "rg --files | wc -l"
fi

run_and_log "validate-quality" "bash 09_automations/01_scripts/05_validate_wo.sh ${WO} quality"

echo >> "${RPT}"
printf 'Logs: `%s`\n' "06_quality/04_reports/${WO}/03_logs" >> "${RPT}"

echo "Quality run finished for ${WO}"
