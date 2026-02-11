#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX [minimal|changed|all]"
  exit 1
fi

WO="$1"
BASE=".roo_template/04_context_packs/${WO}"
mkdir -p "${BASE}/99_extracts"
MODE="${2:-changed}"

if [[ ! -f "${BASE}/01_ContextPack.md" ]]; then
  cat > "${BASE}/01_ContextPack.md" <<EOT
# ${WO} Context Pack

## Background

## Constraints

## Key Files
EOT
fi

if [[ "${MODE}" == "minimal" ]]; then
  cat > "${BASE}/02_FileMap.md" <<EOT
# File Map

| File | Responsibility |
|---|---|
| \`.roo_template/03_work_orders/${WO}/01_WorkOrder.md\` | Work order definition |
| \`src/\` | Implementation scope |
EOT
else
  {
    echo "# File Map"
    echo
    echo "| File | Responsibility |"
    echo "|---|---|"
    list_files() {
      if [[ "${MODE}" == "all" ]]; then
        if command -v rg >/dev/null 2>&1; then
          rg --files
        else
          find . -type f -not -path './.git/*' | sed 's|^\./||'
        fi
        return
      fi

      # Fast default: only files changed against main, plus current WO artifacts.
      if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git show-ref --verify --quiet refs/heads/main; then
        git diff --name-only main...HEAD
        git diff --name-only --cached
        git diff --name-only
      fi
      printf '%s\n' \
        ".roo_template/03_work_orders/${WO}/01_WorkOrder.md" \
        ".roo_template/04_context_packs/${WO}/01_ContextPack.md" \
        "src/"
    }

    list_files \
      | sed '/^$/d' \
      | sort -u \
      | awk '{print "| `"$0"` | TODO |"}'
  } > "${BASE}/02_FileMap.md"
fi

if [[ ! -f "${BASE}/03_API_Contracts.md" ]]; then
  cat > "${BASE}/03_API_Contracts.md" << 'EOT'
# API Contracts

- N/A (fill if applicable)
EOT
fi

if [[ ! -f "${BASE}/04_Decisions_Summary.md" ]]; then
  cat > "${BASE}/04_Decisions_Summary.md" << 'EOT'
# Decisions Summary

- N/A (fill if applicable)
EOT
fi

echo "Prepared context pack for ${WO}: ${BASE} (mode=${MODE})"
