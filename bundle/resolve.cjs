
const path = require('path')
const { alias } = require('../package.json')

Object.keys(alias).forEach(aliasKey => {
  alias[aliasKey] = path.resolve(__dirname, `../${alias[aliasKey]}`)
})

// Recommended by https://github.com/sveltejs/svelte-loader#usage
alias.svelte = path.resolve(__dirname, '../node_modules/svelte')

module.exports = {
  alias,
  // Recommended by https://github.com/sveltejs/svelte-loader#resolvemainfields
  mainFields: [ 'svelte', 'browser', 'module', 'main' ],
}
