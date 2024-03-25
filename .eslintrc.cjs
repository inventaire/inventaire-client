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
    es2022: true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    sourceType: 'module',
    ecmaFeatures: {
      jsx: false,
    },
  },
  plugins: [
    'node-import',
    '@stylistic/ts',
  ],
  extends: [
    // See https://github.com/standard/eslint-config-standard/blob/master/eslintrc.json
    'standard',
    'plugin:@typescript-eslint/eslint-recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:svelte/recommended',
  ],
  rules: {
    'array-bracket-spacing': [ 'error', 'always' ],
    'array-callback-return': [ 'off' ],
    'arrow-parens': [ 'error', 'as-needed' ],
    'comma-dangle': [
      'error',
      {
        arrays: 'always-multiline',
        objects: 'always-multiline',
        imports: 'always-multiline',
        exports: 'always-multiline',
        functions: 'never',
      },
    ],
    eqeqeq: [ 'error', 'smart' ],
    indent: 'off', // Required to set the TS rule
    'implicit-arrow-linebreak': [ 'error', 'beside' ],
    'import/newline-after-import': 'error',
    'import/order': [
      'error',
      {
        pathGroups: [
          { pattern: '#*/**', group: 'internal', position: 'before' },
        ],
        groups: [ 'builtin', 'external', 'internal', 'parent', 'sibling', 'object', 'type' ],
        'newlines-between': 'never',
        alphabetize: { order: 'asc' },
      },
    ],
    'no-ex-assign': [ 'off' ],
    'no-new': [ 'off' ], // TODO: remove once Backbone.Marionette router is replaced
    'no-var': [ 'error' ],
    'node-import/prefer-node-protocol': 2,
    'nonblock-statement-body-position': [ 'error', 'beside' ],
    'object-shorthand': [ 'error', 'properties' ],
    'one-var': [ 'off' ],
    'prefer-arrow-callback': [ 'error' ],
    'prefer-const': [ 'error' ],
    'prefer-rest-params': [ 'off' ],

    '@stylistic/ts/type-annotation-spacing': 'error',
    '@stylistic/ts/space-infix-ops': 'error',
    '@stylistic/ts/object-curly-spacing': [ 'error', 'always' ],

    '@typescript-eslint/keyword-spacing': 'error',
    '@typescript-eslint/ban-ts-comment': 'off',
    '@typescript-eslint/consistent-type-imports': [ 'error', { prefer: 'type-imports' } ],
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/indent': [ 'error', 2, { MemberExpression: 'off' } ],
    '@typescript-eslint/member-delimiter-style': [
      'error',
      {
        multiline: { delimiter: 'none' },
        singleline: { delimiter: 'comma', requireLast: false },
      },
    ],

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
    'svelte/indent': 'error',
    'svelte/max-attributes-per-line': [
      'error',
      {
        multiline: 1,
        singleline: 3,
      },
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
      },
    },
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
    beforeEach: 'readonly',
  },
}
