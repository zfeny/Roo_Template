#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [WO-YYYYMMDD-XXX] [short-title]"
}

next_wo_id() {
  local today seq
  today="$(date +%Y%m%d)"
  seq="001"
  if compgen -G ".roo_template/03_work_orders/WO-${today}-*" >/dev/null; then
    seq="$(
      find .roo_template/03_work_orders -maxdepth 1 -type d -name "WO-${today}-*" \
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

if [[ -e ".roo_template/03_work_orders/${WO}/01_WorkOrder.md" ]]; then
  echo "Work order already exists: .roo_template/03_work_orders/${WO}/01_WorkOrder.md"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
      git switch "${BRANCH}" >/dev/null
      echo "Switched to existing branch ${BRANCH}"
    else
      git switch -c "${BRANCH}" >/dev/null
      echo "Created and switched to branch ${BRANCH}"
    fi
    bash .roo_template/09_automations/01_scripts/06_git_control_check.sh "${WO}" branch
  fi
  echo "Reusing existing work order ${WO}"
  exit 0
fi

mkdir -p ".roo_template/03_work_orders/${WO}/99_refs"

cat > ".roo_template/03_work_orders/${WO}/01_WorkOrder.md" <<EOT
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

cat > ".roo_template/03_work_orders/${WO}/02_Scope.md" << 'EOT'
# Scope

## In Scope

## Out of Scope
EOT

cat > ".roo_template/03_work_orders/${WO}/03_DoD.md" << 'EOT'
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
  bash .roo_template/09_automations/01_scripts/06_git_control_check.sh "${WO}" branch
fi

echo "Created work order scaffold for ${WO}"
echo "Next: fill .roo_template/03_work_orders/${WO}/01_WorkOrder.md and commit stage 'work-order'"
