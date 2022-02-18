#!/usr/bin/env node

// Generate jsconfig.json to please developers using VSCode/Codium
// (see https://code.visualstudio.com/docs/languages/jsconfig)
// while not duplicating module aliases

const { imports } = require('../package.json')
const filename = __filename.replace(`${process.cwd()}/`, '')

const baseUrl = './app'

const jsconfig = {
  __generatedBy: filename,
  module: 'es6',
  compilerOptions: {
    baseUrl,
    paths: {}
  },
  exclude: [
    'node_modules',
    'public',
    'vendor',
    'scripts/assets'
  ]
}

const byPathDepth = (a, b) => b[1].split('/').length - a[1].split('/').length
const rebaseAndFormatPath = path => {
  return path
  .replace(`${baseUrl}/`, '')
  .replace('.js', '')
}

Object.entries(imports)
.filter(([ alias, aliasPath ]) => aliasPath.startsWith(baseUrl))
// Set most specific paths first, so that the AutoImport use them first
.sort(byPathDepth)
.forEach(([ alias, aliasPath ]) => {
  jsconfig.compilerOptions.paths[alias] = [ rebaseAndFormatPath(aliasPath) ]
})

process.stdout.write(`${JSON.stringify(jsconfig, null, 2)}\n`)
