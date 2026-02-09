# Roo Template Pack

## Layout
1. Roo config files for runtime detection: `.roo/` and `.roomodes` at repo root.
2. Roo process artifacts/templates: `.roo_template/`
3. Business source code: `src/` (root, non-numbered)

## Copy to another project
```bash
cp -R /path/to/Roo_Template/.roo_template ./
cp -R /path/to/Roo_Template/.roo ./
cp /path/to/Roo_Template/.roomodes ./
mkdir -p src
```

## Run workflow in target project
```bash
bash .roo_template/09_automations/01_scripts/00_wo.sh kickoff-wo
```

`kickoff-wo` without WO id auto-generates `WO-YYYYMMDD-001` and increments within the same day.
