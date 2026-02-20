const { buildWoFlowArgs, runWhitelisted, artifactPathsForWo } = require('./_lib/allowlist')
const { validateWo, validateAction, collectPolicyWarnings } = require('./_lib/validate')

const TOOL_NAME = 'wo_review'

async function run(input = {}) {
  const wo = validateWo(input.wo)
  validateAction(input.action || 'prepare-review', ['prepare-review'])

  const args = buildWoFlowArgs({ subcommand: 'prepare-review', wo })
  const result = runWhitelisted(args)
  const warnings = collectPolicyWarnings(process.cwd(), wo, 4)

  return {
    status: result.ok ? 'ok' : 'fail',
    tool: TOOL_NAME,
    command: result.command,
    stdout: result.stdout,
    stderr: result.stderr,
    artifacts: artifactPathsForWo(wo),
    warnings,
  }
}

module.exports = {
  name: TOOL_NAME,
  description: 'Prepare reviewer scaffold via wo_flow prepare-review.',
  inputSchema: {
    type: 'object',
    required: ['wo'],
    properties: {
      wo: { type: 'string', description: 'WO-YYYYMMDD-###' },
      action: { type: 'string', enum: ['prepare-review'], default: 'prepare-review' },
    },
  },
  run,
}

if (require.main === module) {
  const payload = process.argv[2] ? JSON.parse(process.argv[2]) : {}
  run(payload)
    .then((output) => {
      console.log(JSON.stringify(output, null, 2))
      process.exit(output.status === 'ok' ? 0 : 2)
    })
    .catch((error) => {
      console.log(JSON.stringify({ status: 'fail', tool: TOOL_NAME, error: error.message }, null, 2))
      process.exit(2)
    })
}
