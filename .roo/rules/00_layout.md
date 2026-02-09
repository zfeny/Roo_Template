# Layout Contract

## Mandatory Structure
1. Roo runtime config MUST be at repo root: `.roo/` and `.roomodes`.
2. Roo process artifacts MUST live under `.roo_template/`.
3. Application source code MUST live under root `src/` (non-numbered).
4. Numbered directories are reserved for Roo process artifacts inside `.roo_template/`.

## Prohibited
1. Do not create root-level process dirs like `03_work_orders/`, `04_context_packs/`, `06_quality/`, `07_delivery_packs/`, `08_review_reports/`.
2. Do not create or use `.roo_template/05_src/`.

## Recovery
If misplaced process files are found at repo root, move them into `.roo_template/` before continuing.
