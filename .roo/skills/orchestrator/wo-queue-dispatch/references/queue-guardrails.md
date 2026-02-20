# Queue Guardrails

## Auto-Approved (Low Risk)
1. Read-only inspections.
2. WO scaffolding and context generation.
3. Deterministic local validation.

## Manual Approval (High Risk)
1. `git push` and remote write operations.
2. Branch merge and release actions.
3. Any destructive command (`rm`, reset, force operations).
