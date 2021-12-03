
const path = require('path')
const { alias } = require('../package.json')

Object.keys(alias).forEach(aliasKey => {
  alias[aliasKey] = path.resolve(__dirname, `../${alias[aliasKey]}`)
})

// Recommended by https://github.com/sveltejs/svelte-loader#usage
alias.svelte = path.resolve(__dirname, '../node_modules/svelte')

alias['backbone.marionette'] = path.resolve(__dirname, '../node_modules/backbone.marionette/lib/backbone.marionette.esm.js')
alias['marionette.approuter'] = path.resolve(__dirname, '../node_modules/marionette.approuter/lib/marionette.approuter.esm.js')

module.exports = {
  alias,
  // Recommended by https://github.com/sveltejs/svelte-loader#resolvemainfields
  mainFields: [ 'svelte', 'browser', 'module', 'main' ],
}
