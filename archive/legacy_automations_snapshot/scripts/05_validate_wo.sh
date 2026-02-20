#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX [quality|delivery]"
  exit 1
fi

WO="$1"
STAGE="${2:-delivery}"
if [[ "${STAGE}" != "quality" && "${STAGE}" != "delivery" ]]; then
  echo "Invalid stage: ${STAGE}. Use quality or delivery."
  exit 1
fi

QDIR=".roo_process/quality/04_reports/${WO}"
RPT="${QDIR}/04_validation_${STAGE}.md"
mkdir -p "${QDIR}"

missing=0
warnings=0

has_fixed_string() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n --fixed-strings "${pattern}" "${file}" >/dev/null 2>&1
  else
    grep -nF "${pattern}" "${file}" >/dev/null 2>&1
  fi
}

check_required() {
  local p="$1"
  if [[ ! -e "${p}" ]]; then
    echo "- [FAIL] Missing: ${p}" >> "${RPT}"
    missing=$((missing + 1))
  else
    echo "- [PASS] Exists: ${p}" >> "${RPT}"
  fi
}

warn_if_contains() {
  local p="$1"
  local marker="$2"
  if [[ -f "${p}" ]] && has_fixed_string "${marker}" "${p}"; then
    echo "- [WARN] Placeholder '${marker}' still present in ${p}" >> "${RPT}"
    warnings=$((warnings + 1))
  fi
}

: > "${RPT}"
{
  echo "# Validation (${STAGE})"
  echo
  echo "- WO: ${WO}"
  echo "- Time: $(date -u '+%Y-%m-%d %H:%M:%SZ')"
  echo
  echo "## Required Checks"
} >> "${RPT}"

check_required ".roo_process/work_orders/${WO}/WorkOrder.md"
check_required ".roo_process/context_packs/${WO}/ContextPack.md"
check_required "${QDIR}/01_quality_report.md"
check_required "${QDIR}/02_commands.md"

WO_FILE=".roo_process/work_orders/${WO}/WorkOrder.md"
if [[ -f "${WO_FILE}" ]]; then
  if has_fixed_string "## Role Assignment (Mandatory)" "${WO_FILE}"; then
    echo "- [PASS] WorkOrder contains role assignment section" >> "${RPT}"
  else
    echo "- [FAIL] WorkOrder missing 'Role Assignment (Mandatory)'" >> "${RPT}"
    missing=$((missing + 1))
  fi

  if has_fixed_string "## Stage Plan (Mandatory)" "${WO_FILE}"; then
    echo "- [PASS] WorkOrder contains stage plan section" >> "${RPT}"
  else
    echo "- [FAIL] WorkOrder missing 'Stage Plan (Mandatory)'" >> "${RPT}"
    missing=$((missing + 1))
  fi

  for core_role in "Orchestrator" "Code" "Reviewer"; do
    if has_fixed_string "| ${core_role} | TBD |" "${WO_FILE}"; then
      echo "- [FAIL] Core role '${core_role}' assignee is still TBD in WorkOrder" >> "${RPT}"
      missing=$((missing + 1))
    else
      echo "- [PASS] Core role '${core_role}' assignee is set" >> "${RPT}"
    fi
  done
fi

if [[ "${STAGE}" == "delivery" ]]; then
  check_required ".roo_process/evidence/${WO}/DeliveryPack.md"
  check_required ".roo_process/evidence/${WO}/02_ChangeList.md"
  check_required ".roo_process/evidence/${WO}/03_SpecCoverage.md"
  check_required ".roo_process/evidence/${WO}/Verification.md"
  check_required ".roo_process/evidence/${WO}/05_RiskNotes.md"

  warn_if_contains ".roo_process/evidence/${WO}/Verification.md" "{WO}"

  if [[ -f ".roo_process/evidence/${WO}/Verification.md" ]]; then
    if has_fixed_string ".roo_process/quality/04_reports/${WO}/01_quality_report.md" ".roo_process/evidence/${WO}/Verification.md"; then
      echo "- [PASS] Verification references quality report" >> "${RPT}"
    else
      echo "- [FAIL] Verification missing quality report reference" >> "${RPT}"
      missing=$((missing + 1))
    fi
  fi
fi

{
  echo
  echo "## Summary"
  echo "- Missing: ${missing}"
  echo "- Warnings: ${warnings}"
} >> "${RPT}"

if [[ ${missing} -gt 0 ]]; then
  echo "Validation failed (${STAGE}) for ${WO}. See ${RPT}" >&2
  exit 2
fi

echo "Validation passed (${STAGE}) for ${WO}. See ${RPT}"
