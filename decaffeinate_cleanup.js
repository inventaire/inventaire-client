#!/usr/bin/env node

// To be run after bulk-decaffeinate is done
// bulk-decaffeinate convert --num-workers 8 --config ~/bulk-decaffeinate.config.js
// cleanup(){ ~/code/inventaire/inventaire/client/decaffeinate_cleanup.js "$@" && eslint --fix "$@" }
// cleanup app/**/*.js scripts/**/*.js test/**/*.js

const path = require('path')
const fs = require('fs')

const cleanupLine = line => {
  line = line
  // .replace(/^(\s+(?!(if|for))\w+) (\(.*\)) \{/g, '$1: $3 => {')
  // .replace(/= (\(.*\)) => {/g, '= $1 => {')
  // .replace(/=> (\(.*\)) => {/g, '=> $1 => {')
  // .replace(/(^\s+if) (\(.*\)) { return\s?(.*) }/g, '$1 $2 return $3')
  // .replace(/(^\s+if) (\(.*\)) { throw\s?(.*) }/g, '$1 $2 throw $3')
  // .replace(/(^\s+else) { return\s?(.*) }/g, '$1 return $2')
  // .replace(/(^\s+else) { throw\s?(.*) }/g, '$1 throw $2')
  .replace(/return done\(\)/, 'done()')
  .replace(/return it\(/, 'it(')
  .replace(/return describe\(/, 'describe(')
  // .replace(/: \((.*)\) => {/g, ' \($1\) {')
  .replace(/^var /, 'const ')
  // .replace('function () {', '() => {')

  if (!(line.match(/^\s*(if|while|for) \(/))) {
    line = line
    // 'fnName (arg) { return .* }' => 'fnName: (arg) => .*'
    // .replace(/^(\s*)(\w+) \((.*)\) \{ return(.*)\}/, '$1$2: ($3) => $4')
    // 'fnName (arg) { .* }' => 'fnName: (arg) => { .* }'
    // .replace(/^(\s*)(\w+) \((.*)\) \{(.*)\}/, '$1$2: ($3) => { $4 }')
    // 'fnName (arg) {' => 'fnName: (arg) => {'
    // .replace(/^(\s*)(\w+) \((.*)\) \{$/, '$1$2: ($3) => {')
  }

  return line
}

const noContextCleanupLine = line => {
  return line
    // 'fnName (arg) {' => 'fnName: (arg) => {'
    .replace(/function \((.*)\) \{/, '($1) => {')
}

const update = file => {
  const current = fs.readFileSync(file).toString()

  let updated = current
    .split('\n')
    .map(cleanupLine)
    .join('\n')

  // Multiline transforms
  updated = updated
    .replace(/(\s*)\}\n\s*\)/, '$1})')

  // if (!updated.includes('this.')) {
  //   updated = updated
  //     .split('\n')
  //     .map(noContextCleanupLine)
  //     .join('\n')
  // }

  if (current !== updated) fs.writeFileSync(file, updated)
}

process.argv.slice(2)
.map(file => path.resolve(file))
.forEach(update)
