const { buildWoFlowArgs, runWhitelisted, artifactPathsForWo } = require('./_lib/allowlist')
const { validateWo, validateSlug, collectPolicyWarnings } = require('./_lib/validate')

const TOOL_NAME = 'wo_kickoff'

async function run(input = {}) {
  const wo = validateWo(input.wo)
  const slug = validateSlug(input.slug)

  const args = buildWoFlowArgs({ subcommand: 'kickoff-lean', wo, slug })
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
  description: 'Kick off a WO branch and minimum scaffold via wo_flow kickoff-lean.',
  inputSchema: {
    type: 'object',
    required: ['wo', 'slug'],
    properties: {
      wo: { type: 'string', description: 'WO-YYYYMMDD-###' },
      slug: { type: 'string', description: 'kebab-case branch suffix' },
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
