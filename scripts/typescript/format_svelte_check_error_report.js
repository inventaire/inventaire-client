import { cyan, grey, red, yellow } from 'tiny-chalk'

const cwd = process.cwd()
const pathBase = grey(`file://${cwd}/`)

export default function (reportLine) {
  const reportParts = reportLine.split(' ').slice(1)
  if (!reportParts[0].startsWith('{')) return
  const report = reportParts.join(' ')
  const { type, filename, start, message, code } = JSON.parse(report)

  // Ignore false server errors
  // such as  `Error: Module '"#lib/regex"' has no exported member 'Integer'.`
  // where svelte-check seems to not properly take the tsconfig.json#references into account
  // thus confusing, in this example, the client #lib import with the server #lib import
  if (!filename.startsWith('app')) return

  const { line, character } = start
  const path = `${pathBase}${cyan(filename)}`
  const category = type === 'ERROR' ? red(type.toLowerCase()) : yellow(type.toLowerCase())
  const tsErrorCode = grey(`TS${code}:`)
  return `\n${path}:${yellow(line + 1)}:${yellow(character + 1)} ${category} ${tsErrorCode}\n${message}\n`
}
