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

QDIR="06_quality/04_reports/${WO}"
RPT="${QDIR}/04_validation_${STAGE}.md"
mkdir -p "${QDIR}"

missing=0
warnings=0

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
  if [[ -f "${p}" ]] && rg -n --fixed-strings "${marker}" "${p}" >/dev/null 2>&1; then
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

check_required "03_work_orders/${WO}/01_WorkOrder.md"
check_required "04_context_packs/${WO}/01_ContextPack.md"
check_required "${QDIR}/01_quality_report.md"
check_required "${QDIR}/02_commands.md"

if [[ "${STAGE}" == "delivery" ]]; then
  check_required "07_delivery_packs/${WO}/01_DeliveryPack.md"
  check_required "07_delivery_packs/${WO}/02_ChangeList.md"
  check_required "07_delivery_packs/${WO}/03_SpecCoverage.md"
  check_required "07_delivery_packs/${WO}/04_Verification.md"
  check_required "07_delivery_packs/${WO}/05_RiskNotes.md"

  warn_if_contains "07_delivery_packs/${WO}/04_Verification.md" "{WO}"

  if [[ -f "07_delivery_packs/${WO}/04_Verification.md" ]]; then
    if rg --fixed-strings "06_quality/04_reports/${WO}/01_quality_report.md" "07_delivery_packs/${WO}/04_Verification.md" >/dev/null 2>&1; then
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
