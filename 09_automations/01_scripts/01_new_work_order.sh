#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX [short-title]"
  exit 1
fi

WO="$1"
SHORT="${2:-work}"
BRANCH="wo/${WO}-${SHORT}"

if [[ -e "03_work_orders/${WO}/01_WorkOrder.md" ]]; then
  echo "Work order already exists: 03_work_orders/${WO}/01_WorkOrder.md"
  exit 2
fi

mkdir -p "03_work_orders/${WO}/99_refs"

cat > "03_work_orders/${WO}/01_WorkOrder.md" <<EOT
# ${WO} Work Order

- Branch: ${BRANCH}
- Status: Draft
- Owner:
- Requester:

## Objective

## Scope

## DoD

## Risks
EOT

cat > "03_work_orders/${WO}/02_Scope.md" << 'EOT'
# Scope

## In Scope

## Out of Scope
EOT

cat > "03_work_orders/${WO}/03_DoD.md" << 'EOT'
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
  bash 09_automations/01_scripts/06_git_control_check.sh "${WO}" branch
fi

echo "Created work order scaffold for ${WO}"
echo "Next: fill 03_work_orders/${WO}/01_WorkOrder.md and commit stage 'work-order'"
