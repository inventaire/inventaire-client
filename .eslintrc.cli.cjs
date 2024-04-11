// eslint-disable-next-line @typescript-eslint/no-var-requires
const eslintrc = require('./.eslintrc.cjs')

// The '../' seems required by the VScode ESlint plugin to avoid the following error in Svelte files
// `Parsing error: Cannot read file '/path/to/client/app/tsconfig.client.json'.eslint`
// but weirdly, the CLI eslint needs './', thus this hacky fix
eslintrc.overrides[0].parserOptions.project = './tsconfig.client.json'

// CLI/pre-commit extra rules
eslintrc.overrides[0].rules['svelte/html-self-closing'] = 'error'
// Helps to spot unsupported features that woul result in
// babel including the corresponding core-js polyfills
// in the bundle served to all users
// See https://github.com/amilajack/eslint-plugin-compat
// NB: some unsupported features are unfortunately not detected
// Ex: Array methods https://github.com/amilajack/eslint-plugin-compat/issues/258
eslintrc.extends.unshift('plugin:compat/recommended')
eslintrc.settings = {
  // Used by eslint-plugin-compat
  polyfills: [
    'Promise',
  ],
}

module.exports = eslintrc
