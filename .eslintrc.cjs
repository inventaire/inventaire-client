// This config file is used by eslint
// See package.json scripts: lint*
// Rules documentation: https://eslint.org/docs/rules/
// Inspect the generated config:
//    eslint --print-config .eslintrc.cjs
module.exports = {
  root: true,
  env: {
    browser: true,
    commonjs: false,
    es2020: true
  },
  parserOptions: {
    sourceType: 'module',
    ecmaVersion: 2020
  },
  extends: [
    // See https://github.com/standard/eslint-config-standard/blob/master/eslintrc.json
    'standard',
    'plugin:svelte/recommended',
  ],
  rules: {
    'array-bracket-spacing': [ 'error', 'always' ],
    // Some map functions may implicitly return undefined,
    // for instance to have it later filtered-out from the array
    'array-callback-return': 'off',
    'arrow-parens': [ 'error', 'as-needed' ],
    'comma-dangle': [
      'error',
      {
        arrays: 'only-multiline',
        objects: 'only-multiline',
        imports: 'only-multiline',
        exports: 'only-multiline',
        functions: 'never'
      }
    ],
    eqeqeq: [ 'error', 'smart' ],
    'implicit-arrow-linebreak': [ 'error', 'beside' ],
    indent: [ 'error', 2, { MemberExpression: 'off' } ],
    // Making the rule settings explicit to prevent to get warnings with svelte components
    // See https://github.com/sveltejs/eslint-plugin-svelte3/issues/82
    'no-multiple-empty-lines': [ 'error', { max: 1, maxBOF: 0, maxEOF: 1 } ],
    // svelte components initialization are a "new" with side-effect
    'no-new': 'off',
    'no-self-assign': 'off',
    'no-var': [ 'error' ],
    'nonblock-statement-body-position': [ 'error', 'beside' ],
    'object-curly-spacing': [ 'error', 'always' ],
    'object-shorthand': [ 'error', 'properties' ],
    // Being able to define several variables on a single line comes very handy with Svelte
    'one-var': 'off',
    // Disabling to prevent editors auto-fix before the variable was reassigned
    'prefer-const': 'off',

    'svelte/no-at-html-tags': 'off',
    'svelte/no-reactive-functions': 'error',
    'svelte/no-reactive-literals': 'error',
    'svelte/no-store-async': 'error',
    'svelte/no-useless-mustaches': 'error',
    'svelte/require-optimized-style-attribute': 'error',
    // 'svelte/require-store-callbacks-use-set-param': 'error',
    'svelte/require-store-reactive-access': 'error',

    'svelte/derived-has-same-inputs-outputs': 'error',
    'svelte/first-attribute-linebreak': 'error',
    'svelte/html-closing-bracket-spacing': 'error',
    'svelte/html-quotes': 'error',
    'svelte/html-self-closing': 'error',
    'svelte/indent': 'error',
    'svelte/max-attributes-per-line': [
      'error',
      {
        multiline: 1,
        singleline: 3
      }
    ],
    'svelte/mustache-spacing': 'error',
    // 'svelte/no-extra-reactive-curlies': 'error',
    'svelte/no-spaces-around-equal-signs-in-attribute': 'error',
    'svelte/prefer-class-directive': 'error',
    'svelte/prefer-style-directive': 'error',
    'svelte/shorthand-attribute': 'error',
    'svelte/shorthand-directive': 'error',
    // 'svelte/sort-attributes': 'error',
    'svelte/spaced-html-comment': 'error',

    'svelte/no-trailing-spaces': 'error',
  },
  overrides: [
    {
      files: [ '*.svelte' ],
      parser: 'svelte-eslint-parser',
      rules: {
        // In Svelte, assignment is used everywhere to update a componenent's state;
        // Turning off this rule allows to write less curly-brackets-loaded inline functions
        // Example:      on:click={() => zoom = !zoom }
        // instead of:   on:click={() => { zoom = !zoom }}
        'no-return-assign': 'off',
      }
    }
  ],
  globals: {
    app: 'writable',
    localStorage: 'writable',
    prerenderReady: 'writable',
    env: 'writable',
    CONFIG: 'writable',
    hasVideoInput: 'writable',
    doesntSupportEnumerateDevices: 'writable',
    FormData: 'writable',
    // Libs
    _: 'writable',
    resize: 'writable',
    $: 'writable',
    Backbone: 'writable',
    Marionette: 'writable',
    L: 'writable',
    FilteredCollection: 'writable',
    Handlebars: 'writable',
    Piwik: 'writable',
    // Browser globals
    alert: 'readonly',
    screen: 'readonly',
    Image: 'readonly',
    FileReader: 'readonly',
    XMLHttpRequest: 'readonly',
    btoa: 'readonly',
    location: 'readonly',
    // Mocha globals
    it: 'readonly',
    xit: 'readonly',
    describe: 'readonly',
    xdescribe: 'readonly',
    beforeEach: 'readonly'
  },
}
