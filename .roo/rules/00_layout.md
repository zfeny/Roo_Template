# Layout Contract

## Mandatory Structure
1. Roo runtime config MUST stay at repo root: `.roo/` and `.roomodes`.
2. Process artifacts MUST stay under `.roo_process/`.
3. Optional frozen specs MUST stay under `_SPECs/`.
4. Product code lives under `src/`.

## Prohibited
1. Do not create or use the legacy template root directory.
2. Do not create root-level process folders such as `03_work_orders/`, `04_context_packs/`, `06_quality/`, `07_delivery_packs/`, `08_review_reports/`.

## Recovery
1. Move misplaced process files into `.roo_process/` before continuing.
