// This config file is used by eslint
// See package.json scripts: lint*
// Rules documentation: https://eslint.org/docs/rules/
// Inspect the generated config:
//    eslint --print-config .eslintrc.cjs
module.exports = {
  root: true,
  env: {
    browser: false,
    commonjs: true,
    es2022: true,
  },
  parserOptions: {
    sourceType: 'module',
  },
  plugins: [
    'node-import',
  ],
  extends: [
    // See https://github.com/standard/eslint-config-standard/blob/master/eslintrc.json
    'standard',
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
  },
}
