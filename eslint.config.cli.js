// Inspect the generated config:
//   eslint --print-config eslint.config.cli.js

// import compat from 'eslint-plugin-compat'
import baseConfig from './eslint.config.js'

export default [
  ...baseConfig,
  // Helps to spot unsupported features that woul result in
  // babel including the corresponding core-js polyfills
  // in the bundle served to all users
  // See https://github.com/amilajack/eslint-plugin-compat
  // NB: some unsupported features are unfortunately not detected
  // Ex: Array methods https://github.com/amilajack/eslint-plugin-compat/issues/258
  // compat.configs['flat/recommended'], // TODO: fix import issue and comment-in
  {
    name: 'cli-extra',
    rules: {
      // Rule disabled for IDEs, as its annoying to get `let` turned into `const` on save,
      // before having the time to write the code that would reassign the variable.
      'prefer-const': [ 'error' ],

    },
    settings: {
      // Used by eslint-plugin-compat
      polyfills: [
        'Promise',
      ],
    },
  },
  {
    files: [ '**/*.svelte', '**/*.svelte.js' ],
    rules: {
      'svelte/html-self-closing': 'error',
    },
  },
]
