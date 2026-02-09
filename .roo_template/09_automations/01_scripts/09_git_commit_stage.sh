#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX <work-order|context|implementation|quality|delivery|review> [message]"
  exit 1
fi

WO="$1"
STAGE="$2"
MSG="${3:-}"
ROLE_EMAIL_DOMAIN="${ROLE_EMAIL_DOMAIN:-roo.local}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository"
  exit 2
fi

bash .roo_template/09_automations/01_scripts/06_git_control_check.sh "${WO}" branch

default_msg() {
  case "${STAGE}" in
    work-order) echo "${WO}: add work order" ;;
    context) echo "${WO}: add context pack" ;;
    implementation) echo "${WO}: implement changes" ;;
    quality) echo "${WO}: add quality report" ;;
    delivery) echo "${WO}: add delivery pack" ;;
    review) echo "${WO}: add review report" ;;
    *) echo "" ;;
  esac
}

stage_role() {
  case "${STAGE}" in
    work-order) echo "Orchestrator" ;;
    context) echo "Librarian" ;;
    implementation) echo "Code" ;;
    quality) echo "QA-Runner" ;;
    delivery) echo "Librarian" ;;
    review) echo "Reviewer" ;;
    *) echo "Agent" ;;
  esac
}

add_stage_files() {
  case "${STAGE}" in
    work-order)
      git add ".roo_template/03_work_orders/${WO}"
      ;;
    context)
      git add ".roo_template/04_context_packs/${WO}"
      ;;
    implementation)
      # Keep implementation scope explicit and auditable.
      git add src .roo_template/srv .roo_template/06_quality/01_tests .roo_template/06_quality/02_lint .roo_template/06_quality/03_security .roo_template/09_automations .roo_template/10_docs .roo .roomodes 2>/dev/null || true
      ;;
    quality)
      bash .roo_template/09_automations/01_scripts/05_validate_wo.sh "${WO}" quality
      git add ".roo_template/06_quality/04_reports/${WO}"
      ;;
    delivery)
      bash .roo_template/09_automations/01_scripts/04_pack_delivery.sh "${WO}"
      git add ".roo_template/07_delivery_packs/${WO}" ".roo_template/06_quality/04_reports/${WO}/04_validation_delivery.md" 2>/dev/null || true
      ;;
    review)
      git add ".roo_template/08_review_reports/${WO}"
      ;;
    *)
      echo "Invalid stage: ${STAGE}"
      exit 1
      ;;
  esac
}

add_stage_files

if git diff --cached --quiet; then
  echo "No staged changes for stage '${STAGE}'"
  exit 3
fi

if [[ -z "${MSG}" ]]; then
  MSG="$(default_msg)"
fi

if [[ ! "${MSG}" =~ ^${WO}:\  ]]; then
  echo "Commit message must start with '${WO}: '"
  exit 4
fi

ROLE_NAME="$(stage_role)"
ROLE_EMAIL="$(echo "${ROLE_NAME}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')@${ROLE_EMAIL_DOMAIN}"
GIT_AUTHOR_NAME="${ROLE_NAME}" \
GIT_AUTHOR_EMAIL="${ROLE_EMAIL}" \
GIT_COMMITTER_NAME="${ROLE_NAME}" \
GIT_COMMITTER_EMAIL="${ROLE_EMAIL}" \
git commit -m "${MSG}"
echo "Committed ${STAGE}: ${MSG}"
