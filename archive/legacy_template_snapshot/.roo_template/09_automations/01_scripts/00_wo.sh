#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  cat <<USAGE
Usage: $0 <command> [WO-YYYYMMDD-XXX] [short]

Commands:
  kickoff-wo | kickoff-lean | new-wo
  prepare-context | prepare-context-all | prepare-review
  quality | quality-full | pack-delivery
  validate-quality | validate-delivery
  review-gate
  git-check-branch | git-check-commit | git-check-merge
  review-artifacts
  commit-work-order | commit-context | commit-implementation
  commit-quality | commit-delivery | commit-review
  merge-wo
  install-hooks
USAGE
  exit 1
fi

CMD="$1"
WO="${2:-}"
SHORT="${3:-work}"
BRANCH=""
if [[ -n "${WO}" ]]; then
  BRANCH="wo/${WO}-${SHORT}"
fi
SCRIPTS_DIR=".roo_template/09_automations/01_scripts"

run() {
  bash "$@"
}

case "${CMD}" in
  kickoff-wo)
    run "${SCRIPTS_DIR}/01_new_work_order.sh" "${WO}" "${SHORT}"
    if [[ -z "${WO}" ]]; then
      WO="$(find .roo_template/03_work_orders -maxdepth 1 -type d -name 'WO-*' | sed 's|^.*/||' | sort | tail -n 1)"
    fi
    run "${SCRIPTS_DIR}/06_git_control_check.sh" "${WO}" branch
    ;;
  kickoff-lean)
    run "${SCRIPTS_DIR}/01_new_work_order.sh" "${WO}" "${SHORT}"
    if [[ -z "${WO}" ]]; then
      WO="$(find .roo_template/03_work_orders -maxdepth 1 -type d -name 'WO-*' | sed 's|^.*/||' | sort | tail -n 1)"
    fi
    run "${SCRIPTS_DIR}/06_git_control_check.sh" "${WO}" branch
    run "${SCRIPTS_DIR}/02_prepare_context.sh" "${WO}" minimal
    ;;
  new-wo)
    run "${SCRIPTS_DIR}/01_new_work_order.sh" "${WO}" "${SHORT}"
    ;;
  prepare-context)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/02_prepare_context.sh" "${WO}"
    ;;
  prepare-context-all)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/02_prepare_context.sh" "${WO}" all
    ;;
  prepare-review)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/11_prepare_review.sh" "${WO}"
    ;;
  quality)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/03_run_quality.sh" "${WO}" fast
    ;;
  quality-full)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/03_run_quality.sh" "${WO}" full
    ;;
  pack-delivery)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/04_pack_delivery.sh" "${WO}"
    ;;
  validate-quality)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/05_validate_wo.sh" "${WO}" quality
    ;;
  validate-delivery)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/05_validate_wo.sh" "${WO}" delivery
    ;;
  review-gate)
    if [[ -n "${WO}" ]]; then
      run "${SCRIPTS_DIR}/12_review_gate.sh" "${WO}"
    else
      run "${SCRIPTS_DIR}/12_review_gate.sh"
    fi
    ;;
  git-check-branch)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/06_git_control_check.sh" "${WO}" branch
    ;;
  git-check-commit)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/06_git_control_check.sh" "${WO}" commit
    ;;
  git-check-merge)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/06_git_control_check.sh" "${WO}" merge
    ;;
  review-artifacts)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/07_prepare_review_artifacts.sh" "${WO}" "${BRANCH}"
    ;;
  commit-work-order)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/09_git_commit_stage.sh" "${WO}" work-order
    ;;
  commit-context)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/09_git_commit_stage.sh" "${WO}" context
    ;;
  commit-implementation)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/09_git_commit_stage.sh" "${WO}" implementation
    ;;
  commit-quality)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/09_git_commit_stage.sh" "${WO}" quality
    ;;
  commit-delivery)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/09_git_commit_stage.sh" "${WO}" delivery
    ;;
  commit-review)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/09_git_commit_stage.sh" "${WO}" review
    ;;
  merge-wo)
    [[ -n "${WO}" ]] || { echo "WO is required"; exit 1; }
    run "${SCRIPTS_DIR}/10_git_merge_wo.sh" "${WO}" "${SHORT}"
    ;;
  install-hooks)
    run "${SCRIPTS_DIR}/08_install_git_hooks.sh"
    ;;
  *)
    echo "Unknown command: ${CMD}"
    exit 1
    ;;
esac
