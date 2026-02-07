#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 WO-YYYYMMDD-XXX"
  exit 1
fi

WO="$1"
BASE="04_context_packs/${WO}"
mkdir -p "${BASE}/99_extracts"

if [[ ! -f "${BASE}/01_ContextPack.md" ]]; then
  cat > "${BASE}/01_ContextPack.md" <<EOT
# ${WO} Context Pack

## Background

## Constraints

## Key Files
EOT
fi

{
  echo "# File Map"
  echo
  echo "| File | Responsibility |"
  echo "|---|---|"
  rg --files | awk '{print "| `"$0"` | TODO |"}'
} > "${BASE}/02_FileMap.md"

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

echo "Prepared context pack for ${WO}: ${BASE}"
