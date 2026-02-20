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
5. Start implementation child in Librarian, then use `switch_mode` for Librarian/Code/Debug intra-WO role changes.
6. Maintain Roo built-in todo (`update_todo_list`) for multi-step orchestration before closing tasks.
7. Record queue decisions in `.roo_process/docs/QUEUE_POLICY.md` terms.

## References
- Queue guardrails: `references/queue-guardrails.md`
