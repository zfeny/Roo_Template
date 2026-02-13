# Git Hook Templates

Install into `.git/hooks/`:

```bash
cp .roo_template/09_automations/02_git_hooks/commit-msg .git/hooks/commit-msg
cp .roo_template/09_automations/02_git_hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/commit-msg .git/hooks/pre-push
```

These hooks enforce WO branch/commit conventions for local Git workflow.
