#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX"
  exit 1
fi

WO="$1"
DP="07_delivery_packs/${WO}"
mkdir -p "${DP}/99_artifacts"

CH="${DP}/02_ChangeList.md"
SP="${DP}/03_SpecCoverage.md"
VF="${DP}/04_Verification.md"

{
  echo "# Change List"
  echo
  echo "| File | Status |"
  echo "|---|---|"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git diff --name-status HEAD | awk '{print "| `"$2"` | "$1" |"}'
  else
    echo "| N/A | Not a git repository |"
  fi
} > "${CH}"

if [[ ! -f "${SP}" ]]; then
  cat > "${SP}" << 'EOT'
# Spec Coverage

| Spec Clause | Implementation Evidence |
|---|---|
EOT
fi

cat > "${VF}" <<EOT
# Verification

- Quality Report: \`06_quality/04_reports/${WO}/01_quality_report.md\`
- Commands: \`06_quality/04_reports/${WO}/02_commands.md\`
EOT

bash 09_automations/01_scripts/05_validate_wo.sh "${WO}" delivery

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CUR_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "${CUR_BRANCH}" =~ ^wo/${WO}-[a-z0-9._-]+$ ]] && git show-ref --verify --quiet refs/heads/main; then
    bash 09_automations/01_scripts/07_prepare_review_artifacts.sh "${WO}" "${CUR_BRANCH}"
  fi
fi

echo "Delivery pack assembled for ${WO}"
