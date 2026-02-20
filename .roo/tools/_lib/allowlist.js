const path = require('node:path')
const { spawnSync } = require('node:child_process')

const ROOT = process.cwd()
const WO_FLOW_SCRIPT = '.roo_process/scripts/wo_flow.py'
const REVIEW_GATE_SCRIPT = '.roo_process/scripts/review_gate.py'

const WO_FLOW_SUBCOMMANDS = new Set([
  'kickoff-lean',
  'prepare-context',
  'prepare-context-all',
  'pack-delivery',
  'prepare-review',
  'validate-delivery',
])

function buildWoFlowArgs({ subcommand, wo, slug }) {
  if (!WO_FLOW_SUBCOMMANDS.has(subcommand)) {
    throw new Error(`Subcommand not allowed: ${subcommand}`)
  }

  const args = ['python3', WO_FLOW_SCRIPT, subcommand, '--wo', wo]
  if (subcommand === 'kickoff-lean') {
    if (!slug) throw new Error('kickoff-lean requires slug')
    args.push('--slug', slug)
  }
  return args
}

function buildReviewGateArgs({ wo, strict, specPaths }) {
  const args = ['python3', REVIEW_GATE_SCRIPT, '--feature', wo]
  args.push(strict ? '--strict' : '--no-strict')
  for (const p of specPaths) {
    args.push('--spec-path', p)
  }
  return args
}

function isAllowedArgs(args) {
  if (!Array.isArray(args) || args.length < 3) return false
  if (args[0] !== 'python3') return false

  if (args[1] === WO_FLOW_SCRIPT) {
    return WO_FLOW_SUBCOMMANDS.has(args[2])
  }

  if (args[1] === REVIEW_GATE_SCRIPT) {
    return true
  }

  return false
}

function runWhitelisted(args, { cwd = ROOT, timeoutMs = 120000 } = {}) {
  if (!isAllowedArgs(args)) {
    throw new Error(`Command rejected by allowlist: ${args.join(' ')}`)
  }

  const cmd = args[0]
  const cmdArgs = args.slice(1)
  const result = spawnSync(cmd, cmdArgs, {
    cwd,
    encoding: 'utf8',
    timeout: timeoutMs,
  })

  const errorMessage = result.error ? String(result.error.message || result.error) : ''
  const stderr = [result.stderr || '', errorMessage ? `[spawnSync] ${errorMessage}` : '']
    .filter(Boolean)
    .join('\n')

  return {
    ok: result.status === 0 && !result.error,
    statusCode: result.status ?? -1,
    signal: result.signal,
    command: [cmd, ...cmdArgs].join(' '),
    stdout: result.stdout || '',
    stderr,
    timedOut: Boolean(result.error && result.error.code === 'ETIMEDOUT'),
  }
}

function artifactPathsForWo(wo) {
  return [
    path.join('.roo_process', 'work_orders', wo),
    path.join('.roo_process', 'context_packs', wo),
    path.join('.roo_process', 'quality', wo),
    path.join('.roo_process', 'evidence', wo),
    path.join('.roo_process', 'review_reports', wo),
  ]
}

module.exports = {
  buildWoFlowArgs,
  buildReviewGateArgs,
  runWhitelisted,
  artifactPathsForWo,
}
