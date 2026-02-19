#!/usr/bin/env bash
set -euo pipefail

# Backward-compatible wrapper: prefer root entrypoint.
exec bash ./bootstrap_roo_from_github.sh "$@"
