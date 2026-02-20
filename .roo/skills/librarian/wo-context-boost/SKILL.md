---
name: wo-context-boost
description: Deepen context and traceability for high-risk WO execution. Use when changed-only context is insufficient for implementation or review.
---

# WO Context Boost

Use this skill only when lean context is insufficient.

## Steps
1. Expand file map: `python3 .roo_process/scripts/wo_flow.py prepare-context-all --wo <WO_ID>`.
2. Use web search for time-sensitive external facts (API/version/changelog/standard changes) when relevant.
3. Update `.roo_process/context_packs/<WO_ID>/API_Contracts.md` for interface impacts.
4. Update `.roo_process/context_packs/<WO_ID>/Decisions_Summary.md` with tradeoffs and source notes.
5. Ensure all additions directly support active implementation or review questions.

## Output Checklist
- Context pack is traceable and reviewable.
- Added docs map to current WO scope.
- External references are time-bounded and source-attributed when web search was used.
