# Debug Playbook

## Reproduce
1. Pin command, seed, and environment assumptions.
2. Capture command output in `.roo_process/quality/<WO_ID>/logs/`.

## Isolate
1. Minimize input and touched files.
2. Confirm a single root cause hypothesis.

## Fix
1. Patch only required scope.
2. Re-run failing command and one adjacent regression check.
