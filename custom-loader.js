// A custom loader to be able to call ES modules, which
// - might make use of package.json#alias to resolve imports
// - might refer to global variables

// Example use:
//     node --no-warnings --loader ./custom-loader.js --es-module-specifier-resolution=node
// Inspired by https://github.com/ilearnio/module-alias/issues/59#issuecomment-500480450
// Target: NodeJS v14.13.0
// See https://nodejs.org/api/esm.html#esm_experimental_loaders

import path from 'path'
import fs from 'fs'
import underscore from 'underscore'

const browserGlobalsMocks = {
  _: underscore
}

global.window = browserGlobalsMocks
Object.assign(global, browserGlobalsMocks)

const npmPackage = JSON.parse(fs.readFileSync('./package.json').toString())

const getAliases = () => {
  const base = process.cwd()

  const aliases = npmPackage.alias || {}

  const absoluteAliases = Object.keys(aliases).reduce((acc, key) => aliases[key][0] === '/'
    ? acc
    : { ...acc, [key]: path.join(base, aliases[key]) },
  aliases)

  return absoluteAliases
}

const isAliasInSpecifier = (path, alias) => {
  return path.indexOf(alias) === 0 && (path.length === alias.length || path[alias.length] === '/')
}

const aliases = getAliases()

export const resolve = (specifier, context, defaultResolve) => {
  const alias = Object.keys(aliases).find(key => isAliasInSpecifier(specifier, key))

  const newSpecifier = alias === undefined
    ? specifier
    : path.join(aliases[alias], specifier.substr(alias.length))

  return defaultResolve(newSpecifier, context, defaultResolve)
}

export const getFormat = async (url, context, defaultGetFormat) => {
  const res = await defaultGetFormat(url, context, defaultGetFormat)
  res.format = res.format || 'commonjs'
  return res
}
