#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX [fast|full]"
  exit 1
fi

WO="$1"
PROFILE="${2:-fast}"
OUT_DIR=".roo_template/06_quality/04_reports/${WO}"
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

if [[ "${PROFILE}" == "full" ]]; then
  if [[ -f "package.json" ]]; then
    run_and_log "npm-test" "npm test --silent"
  fi
  if command -v pytest >/dev/null 2>&1; then
    run_and_log "pytest" "pytest -q"
  fi
else
  echo "- profile: fast (skip full test suites)" >> "${RPT}"
fi

if command -v rg >/dev/null 2>&1; then
  run_and_log "repo-scan" "rg --files | wc -l"
else
  run_and_log "repo-scan" "find . -type f -not -path './.git/*' | wc -l"
fi

run_and_log "validate-quality" "bash .roo_template/09_automations/01_scripts/05_validate_wo.sh ${WO} quality"

echo >> "${RPT}"
printf 'Logs: `%s`\n' ".roo_template/06_quality/04_reports/${WO}/03_logs" >> "${RPT}"

echo "Quality run finished for ${WO}"
