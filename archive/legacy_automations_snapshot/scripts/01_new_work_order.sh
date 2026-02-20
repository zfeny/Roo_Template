#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [WO-YYYYMMDD-XXX] [short-title]"
}

next_wo_id() {
  local today seq
  today="$(date +%Y%m%d)"
  seq="001"
  if compgen -G ".roo_process/work_orders/WO-${today}-*" >/dev/null; then
    seq="$(
      find .roo_process/work_orders -maxdepth 1 -type d -name "WO-${today}-*" \
      | sed -E "s|^.*/WO-${today}-([0-9]{3}).*|\\1|" \
      | awk '/^[0-9]{3}$/{print}' \
      | sort -n \
      | tail -n 1 \
      | awk '{printf "%03d", $1 + 1}'
    )"
  fi
  echo "WO-${today}-${seq}"
}

WO="${1:-}"
SHORT="${2:-work}"
if [[ -z "${WO}" ]]; then
  WO="$(next_wo_id)"
  echo "Auto-generated WO: ${WO}"
fi
BRANCH="wo/${WO}-${SHORT}"

if [[ -e ".roo_process/work_orders/${WO}/WorkOrder.md" ]]; then
  echo "Work order already exists: .roo_process/work_orders/${WO}/WorkOrder.md"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
      git switch "${BRANCH}" >/dev/null
      echo "Switched to existing branch ${BRANCH}"
    else
      git switch -c "${BRANCH}" >/dev/null
      echo "Created and switched to branch ${BRANCH}"
    fi
    bash .roo_process/automations/scripts/06_git_control_check.sh "${WO}" branch
  fi
  echo "Reusing existing work order ${WO}"
  exit 0
fi

mkdir -p ".roo_process/work_orders/${WO}/99_refs"

cat > ".roo_process/work_orders/${WO}/WorkOrder.md" <<EOT
# ${WO} Work Order

- Branch: ${BRANCH}
- Status: Draft
- Owner: TBD
- Requester: TBD

## Objective

## Scope

## DoD

## Role Assignment (Mandatory)

| Role | Assignee | Responsibilities | Deliverables |
|---|---|---|---|
| Orchestrator | TBD | WO planning, branch control, stage dispatch, merge decision | \`WorkOrder.md\`, branch policy checks |
| Code | TBD | Implementation and required workflow artifacts in lean path | \`src/*\`, quality and delivery docs |
| Reviewer | TBD | Independent acceptance and PASS/FAIL verdict | \`.roo_process/review_reports/${WO}/Review.md\` |
| Librarian (Optional) | N/A | Context and delivery curation when explicitly needed | context/delivery pack updates |
| Architect (Optional) | N/A | Architecture planning for risky scope | design notes/contracts |
| QA Runner (Optional) | N/A | Execute checks and evidence capture | quality reports/logs |

## Stage Plan (Mandatory)

| Stage | Owner Role | Entry Criteria | Exit Deliverable |
|---|---|---|---|
| Kickoff | Orchestrator | SPEC digested | WO + branch issued |
| Build | Code | Gate A passed | implementation commit(s) |
| Quality | Code / QA Runner | build done | quality report |
| Review | Reviewer | delivery pack complete | \`Verdict: PASS|FAIL\` |
| Merge | Orchestrator | PASS + git gate | merge commit |

## Risks
EOT

cat > ".roo_process/work_orders/${WO}/02_Scope.md" << 'EOT'
# Scope

## In Scope

## Out of Scope
EOT

cat > ".roo_process/work_orders/${WO}/03_DoD.md" << 'EOT'
# Definition of Done

- [ ] Work order completed and committed
- [ ] Context pack completed and committed
- [ ] Delivery pack completed and committed
- [ ] Review report completed and committed
EOT

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
    git switch "${BRANCH}" >/dev/null
    echo "Switched to existing branch ${BRANCH}"
  else
    git switch -c "${BRANCH}" >/dev/null
    echo "Created and switched to branch ${BRANCH}"
  fi
  bash .roo_process/automations/scripts/06_git_control_check.sh "${WO}" branch
fi

echo "Created work order scaffold for ${WO}"
echo "Next: fill .roo_process/work_orders/${WO}/WorkOrder.md and commit stage 'work-order'"
