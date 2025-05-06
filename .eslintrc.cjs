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
    extraFileExtensions: [ '.svelte' ],
  },
  plugins: [
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
    // Leave that job to @typescript-eslint/no-restricted-imports
    "no-restricted-imports": "off",
    'no-var': [ 'error' ],
    'nonblock-statement-body-position': [ 'error', 'beside' ],
    'object-shorthand': [ 'error', 'properties' ],
    'one-var': [ 'off' ],
    'prefer-arrow-callback': [ 'error' ],
    // Rule disabled for IDEs, as its annoying to get `let` turned into `const` on save,
    // before having the time to write the code that would reassign the variable.
    // But this rule is then on in .eslintrc.cli.cjs
    'prefer-const': [ 'off' ],
    'prefer-rest-params': [ 'off' ],

    '@stylistic/ts/type-annotation-spacing': 'error',
    '@stylistic/ts/space-infix-ops': 'error',
    '@stylistic/ts/object-curly-spacing': [ 'error', 'always' ],
    '@stylistic/ts/indent': [ 'error', 2, { MemberExpression: 'off' } ],
    '@stylistic/ts/keyword-spacing': 'error',
    '@stylistic/ts/member-delimiter-style': [
      'error',
      {
        multiline: { delimiter: 'none' },
        singleline: { delimiter: 'comma', requireLast: false },
      },
    ],

    '@typescript-eslint/ban-ts-comment': 'off',
    '@typescript-eslint/consistent-type-imports': [ 'error', { prefer: 'type-imports' } ],
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-restricted-imports': [
      'error',
      {
        patterns: [{
          group: [ '*server/' ],
          message: "Only types can be imported from the server",
          allowTypeImports: true,
        }],
      }
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

    // Let the svelte compiler do that work
    'svelte/valid-compile': 'off',
  },
  overrides: [
    {
      files: [ '*.svelte' ],
      parser: 'svelte-eslint-parser',
      parserOptions: {
        // See https://github.com/sveltejs/eslint-plugin-svelte#parser-configuration
        parser: '@typescript-eslint/parser',

        // Specifying the `project` is recommended by eslint-plugin-svelte documentation, but linting TS in Svelte component still works without, while keeping it adds huge delays.
        // The difference can be seen from ESLint debug logs: `export DEBUG=typescript-eslint:* ; npm run lint`:
        //
        // * Without `project`, logs typically look like this for every .svelte file (similar to .ts files):
        //     typescript-eslint:typescript-estree:createSourceFile Getting AST without type information in TS mode for: app/lib/components/flash.svelte +42ms
        //
        // * With `project`:
        //   typescript-eslint:typescript-estree:parser:parseSettings:resolveProjectList parserOptions.project (excluding ignored) matched projects: Set(1) { 'tsconfig.client.json' } +0ms
        //   typescript-eslint:typescript-estree:createWatchProgram File did not belong to any existing programs, moving to create/update. app/lib/components/flash.svelte +0ms
        //   typescript-eslint:typescript-estree:createWatchProgram Creating watch program for tsconfig.client.json. +1ms
        //   typescript-eslint:typescript-estree:createWatchProgram Found program for file. app/lib/components/flash.svelte +4s
        //   typescript-eslint:typescript-estree:createProjectProgram Creating project program for: app/lib/components/flash.svelte +0ms
        //   typescript-eslint:parser:parser Resolved libs from program: [ 'esnext.full' ] +0ms
        //   typescript-eslint:typescript-estree:createSourceFile Getting AST without type information in TS mode for: app/lib/components/link.svelte +4s
        //   typescript-eslint:typescript-estree:createWatchProgram Found existing program for file. app/lib/components/link.svelte +401ms
        //   typescript-eslint:typescript-estree:createProjectProgram Creating project program for: app/lib/components/link.svelte +578ms
        //   typescript-eslint:parser:parser Resolved libs from program: [ 'esnext.full' ] +576ms
        //
        // project: './tsconfig.client.json',

        extraFileExtensions: [ '.svelte' ],
      },
      rules: {
        // In Svelte, assignment is used everywhere to update a componenent's state;
        // Turning off this rule allows to write less curly-brackets-loaded inline functions
        // Example:      on:click={() => zoom = !zoom }
        // instead of:   on:click={() => { zoom = !zoom }}
        'no-return-assign': 'off',
        // Triggers errors in reactive blocks
        '@typescript-eslint/no-unused-expressions': 'off',
      },
    },
  ],
  globals: {
    app: 'writable',
    localStorage: 'writable',
    env: 'writable',
    CONFIG: 'writable',
    FormData: 'writable',
    // Libs
    L: 'writable',
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
