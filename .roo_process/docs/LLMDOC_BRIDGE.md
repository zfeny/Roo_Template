# _llmdoc Bridge (Roo Integration)

## Goal
Integrate an `_llmdoc/` knowledge tree into Roo collaboration flow as a default required stage, without replacing `.roo_process/` as source of truth.

## Source Basis
TokenRollAI cc-plugin defines a documentation-first loop with commands such as:
- `initDoc`
- `readDoc`
- `updateDoc`
- `selectDoc`
- role prompts like `recorder`, `scout`, `investigator`

Reference:
- <https://github.com/TokenRollAI/cc-plugin/blob/main/README.md>
- <https://github.com/TokenRollAI/cc-plugin/blob/main/README.zh-CN.md>

## Mapping to Roo
1. Init doc tree:
   - Tool-first: `node .roo/tools/wo_docs.js '{"action":"init-doc"}'`
   - Fallback: `python3 .roo_process/scripts/llmdoc_bridge.py init-doc`
2. Update one WO doc index:
   - Tool-first: `node .roo/tools/wo_docs.js '{"action":"update-doc","wo":"WO-YYYYMMDD-001"}'`
   - Fallback: `python3 .roo_process/scripts/llmdoc_bridge.py update-doc --wo WO-YYYYMMDD-001`
3. Read/select docs:
   - Use existing Roo read workflow against `_llmdoc/` files.
4. Role prompt intent:
   - `recorder` -> Librarian (documentation traceability)
   - `scout` -> Librarian + browser (fresh external facts)
   - `investigator` -> Debug/Reviewer depending on purpose

## Ownership
1. Primary owner: Librarian.
2. Orchestrator only dispatches and verifies sync completion in WO checklist.
3. Code/Debug can read `_llmdoc/` but should not be the default maintainer.
4. Mandatory execution chain per WO: `Librarian(update-doc pre-code) -> Code(dev) -> Librarian(update-doc post-code)`.
5. Librarian must perform web search by default and record at least 3 potentially stale points from WO context before handoff to Code.

## Directory Contract
- `_llmdoc/` is default-enabled and stays at repo root.
- Bridged WO doc path: `_llmdoc/03-work-orders/<WO>.md`
- Index path: `_llmdoc/03-work-orders/INDEX.md`
- Facts remain authoritative in `.roo_process/` artifacts.
- Legacy `llmdoc/` (if found) is auto-migrated to `_llmdoc/` by `llmdoc_bridge.py init-doc`.

## Recommended Trigger Points
1. After `prepare-context`: initialize `_llmdoc/` if missing.
2. Before handoff to Code: Librarian runs `update-doc` for current WO.
3. Code finishes development and switches back to Librarian: Librarian runs `update-doc` again.
4. Before project status report: refresh `_llmdoc/03-work-orders/INDEX.md`.
