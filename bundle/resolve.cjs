const path = require('path')
const { imports } = require('../package.json')

// Same aliases as package.json#imports, but intended
// for other asset types than JS files (ex: scss, hbs, svelte, jpg, woff)
// NB: Those being specific to Webpack, other node process (such as mocha)
// won't be able to resolve imports from non-JS files
const alias = {}

for (const [ key, value ] of Object.entries(imports)) {
  alias[key.replace('/*', '')] = value.replace('/*.js', '')
}

// Rule required to import assets in CSS url()
alias.assets = './app/assets'

for (const [ key, value ] of Object.entries(alias)) {
  alias[key] = path.resolve(__dirname, `../${value}`)
}

// Recommended by https://github.com/sveltejs/svelte-loader#usage
alias.svelte = path.resolve(__dirname, '../node_modules/svelte/src/runtime')

alias['backbone.marionette'] = path.resolve(__dirname, '../node_modules/backbone.marionette/lib/backbone.marionette.esm.js')
alias['marionette.approuter'] = path.resolve(__dirname, '../node_modules/marionette.approuter/lib/marionette.approuter.esm.js')

module.exports = {
  extensions: [ '.js', '.cjs', '.ts', '.svelte', '.hbs' ],
  alias,
  // Recommended by https://github.com/sveltejs/svelte-loader#resolvemainfields
  mainFields: [ 'svelte', 'browser', 'module', 'main' ],
  // Required to use the original component source code, see https://github.com/sveltejs/svelte-loader#resolveconditionnames
  conditionNames: [ 'svelte' ],
}
