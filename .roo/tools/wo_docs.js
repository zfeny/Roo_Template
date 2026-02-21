const { buildLlmdocArgs, runWhitelisted } = require('./_lib/allowlist')
const { validateWo, validateAction, collectPolicyWarnings } = require('./_lib/validate')

const TOOL_NAME = 'wo_docs'

function docsArtifactsForWo(wo) {
  const artifacts = ['_llmdoc/']
  if (wo) artifacts.push(`_llmdoc/03-work-orders/${wo}.md`)
  return artifacts
}

async function run(input = {}) {
  const action = validateAction(input.action || 'update-doc', ['init-doc', 'update-doc'])
  const wo = action === 'update-doc' ? validateWo(input.wo) : undefined

  const args = buildLlmdocArgs({ subcommand: action, wo })
  const result = runWhitelisted(args)
  const warnings = wo ? collectPolicyWarnings(process.cwd(), wo, 4) : []

  return {
    status: result.ok ? 'ok' : 'fail',
    tool: TOOL_NAME,
    command: result.command,
    stdout: result.stdout,
    stderr: result.stderr,
    artifacts: docsArtifactsForWo(wo),
    warnings,
  }
}

module.exports = {
  name: TOOL_NAME,
  description: 'Bridge Roo WO artifacts into _llmdoc documentation structure (mandatory Librarian stage).',
  inputSchema: {
    type: 'object',
    properties: {
      action: { type: 'string', enum: ['init-doc', 'update-doc'], default: 'update-doc' },
      wo: { type: 'string', description: 'WO-YYYYMMDD-### (required for update-doc)' },
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
