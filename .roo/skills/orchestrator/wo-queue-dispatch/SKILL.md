---
name: wo-queue-dispatch
description: Dispatch low-risk WO operations through an efficiency-first queue with high-risk command guards. Use when Orchestrator coordinates repetitive WO actions across tasks.
---

# WO Queue Dispatch

Use queueing to reduce orchestration latency while preserving safety.

## Workflow
1. Classify commands into low-risk and high-risk buckets.
2. Queue low-risk, repeatable operations for automatic approval.
3. Block high-risk operations (`git push`, merge, destructive commands) for explicit confirmation.
4. Use `new_task` for boundary handoffs (Orchestrator -> Implementation, Orchestrator -> Reviewer).
5. Use `switch_mode` for intra-WO implementation role changes inside the active child task.
6. Record queue decisions in `.roo_process/docs/QUEUE_POLICY.md` terms.

## References
- Queue guardrails: `references/queue-guardrails.md`
