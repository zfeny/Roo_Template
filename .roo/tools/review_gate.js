const { buildReviewGateArgs, runWhitelisted, artifactPathsForWo } = require('./_lib/allowlist')
const { validateWo, validateStrict, validateSpecPaths, collectPolicyWarnings } = require('./_lib/validate')

const TOOL_NAME = 'review_gate'

async function run(input = {}) {
  const wo = validateWo(input.wo)
  const strict = validateStrict(input.strict)
  const specPaths = validateSpecPaths(input.specPaths)

  const args = buildReviewGateArgs({ wo, strict, specPaths })
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
  description: 'Run reviewer gate with strict and optional spec freeze paths.',
  inputSchema: {
    type: 'object',
    required: ['wo'],
    properties: {
      wo: { type: 'string', description: 'WO-YYYYMMDD-###' },
      strict: { type: 'boolean', default: true },
      specPaths: { type: 'array', items: { type: 'string' } },
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
