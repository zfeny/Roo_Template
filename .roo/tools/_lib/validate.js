const fs = require('node:fs')
const path = require('node:path')
const { spawnSync } = require('node:child_process')

const WO_PATTERN = /^WO-\d{8}-\d+(?:-R\d+)?$/
const SLUG_PATTERN = /^[a-z0-9]+(?:-[a-z0-9]+)*$/
const SHELL_META_PATTERN = /[;|`]|\$\(|&&|\|\|/

function assertString(name, value) {
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(`${name} must be a non-empty string`)
  }
  return value.trim()
}

function rejectShellMeta(name, value) {
  if (SHELL_META_PATTERN.test(value)) {
    throw new Error(`${name} contains forbidden shell meta characters`)
  }
}

function validateWo(wo) {
  const value = assertString('wo', wo)
  rejectShellMeta('wo', value)
  if (!WO_PATTERN.test(value)) {
    throw new Error('wo must match WO-YYYYMMDD-### (optional -Rn)')
  }
  return value
}

function validateSlug(slug) {
  const value = assertString('slug', slug)
  rejectShellMeta('slug', value)
  if (!SLUG_PATTERN.test(value)) {
    throw new Error('slug must match [a-z0-9-] and cannot start/end with -')
  }
  return value
}

function validateMode(mode) {
  const value = assertString('mode', mode).toLowerCase()
  if (value !== 'changed' && value !== 'all') {
    throw new Error('mode must be changed or all')
  }
  return value
}

function validateAction(action, allowed) {
  const value = assertString('action', action)
  if (!allowed.includes(value)) {
    throw new Error(`action must be one of: ${allowed.join(', ')}`)
  }
  return value
}

function validateStrict(strict) {
  if (typeof strict === 'undefined') return true
  if (typeof strict !== 'boolean') {
    throw new Error('strict must be boolean')
  }
  return strict
}

function validateSpecPaths(specPaths) {
  if (typeof specPaths === 'undefined') return []
  if (!Array.isArray(specPaths)) {
    throw new Error('specPaths must be an array of relative paths')
  }
  return specPaths.map((raw, idx) => {
    const value = assertString(`specPaths[${idx}]`, raw)
    rejectShellMeta(`specPaths[${idx}]`, value)
    if (path.isAbsolute(value) || value.includes('..')) {
      throw new Error(`specPaths[${idx}] must be workspace-relative and cannot include ..`)
    }
    return value
  })
}

function collectPolicyWarnings(rootDir, wo, stepCount = 4) {
  const warnings = []
  const workOrderDir = path.join(rootDir, '.roo_process', 'work_orders', wo)
  const todoJson = path.join(workOrderDir, 'todo.json')
  const todoMd = path.join(workOrderDir, 'TODO.md')

  if (stepCount >= 4 && !fs.existsSync(todoJson) && !fs.existsSync(todoMd)) {
    warnings.push('Todo policy warning: no WO-level todo.json/TODO.md found under .roo_process/work_orders/<WO>/ (Roo built-in session todo must still be managed via update_todo_list)')
  }

  try {
    const list = spawnSync('git', ['worktree', 'list'], { cwd: rootDir, encoding: 'utf8' })
    if (list.status === 0) {
      const lines = list.stdout.split('\n').filter(Boolean)
      if (lines.length > 1) {
        warnings.push('Worktree policy warning: multiple worktrees detected, ensure WO evidence isolation')
      }
    }
  } catch {
    // Ignore non-git environments.
  }

  return warnings
}

module.exports = {
  validateWo,
  validateSlug,
  validateMode,
  validateAction,
  validateStrict,
  validateSpecPaths,
  collectPolicyWarnings,
}
