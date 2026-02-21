---
name: wo-context-boost
description: Deepen context and traceability for high-risk WO execution. Use when changed-only context is insufficient for implementation or review.
---

# WO Context Boost

Use this skill only when lean context is insufficient.

## Steps
1. Expand file map: `python3 .roo_process/scripts/wo_flow.py prepare-context-all --wo <WO_ID>`.
2. Identify at least 3 potentially stale points from WorkOrder/Context.
3. Use web search for each stale point (API/version/changelog/standard changes).
4. Update `.roo_process/context_packs/<WO_ID>/API_Contracts.md` for interface impacts.
5. Update `.roo_process/context_packs/<WO_ID>/Decisions_Summary.md` with stale-point list, tradeoffs, and source notes.
6. Run `_llmdoc` sync before handoff to Code: `node .roo/tools/wo_docs.js '{"action":"update-doc","wo":"<WO_ID>"}'` (or script fallback).
7. Ensure all additions directly support active implementation or review questions.

## Output Checklist
- Context pack is traceable and reviewable.
- Added docs map to current WO scope.
- At least 3 stale points were searched and source-attributed.
- `_llmdoc/03-work-orders/<WO_ID>.md` was synchronized pre-code.
