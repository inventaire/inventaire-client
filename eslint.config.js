// Inspect the generated config:
//   eslint --print-config eslint.config.js

import js from '@eslint/js'
import stylistic from '@stylistic/eslint-plugin'
import { globalIgnores } from 'eslint/config'
import { createTypeScriptImportResolver } from 'eslint-import-resolver-typescript'
import importxPlugin from 'eslint-plugin-import-x'
import nodeImport from 'eslint-plugin-node-import'
import svelte from 'eslint-plugin-svelte'
import globals from 'globals'
import ts from 'typescript-eslint'
import svelteConfig from './svelte.config.cjs'

export default ts.config(
  globalIgnores([
    'public/dist',
    '**/node_modules',
    '**/vendor',
    'scripts/assets',
    'app/assets/js/languages_data.ts',
  ]),
  js.configs.recommended,
  // TODO: replace with ts.configs.recommendedTypeChecked once tsconfig.json has strict=true
  ...ts.configs.recommended,
  importxPlugin.flatConfigs.recommended,
  importxPlugin.flatConfigs.typescript,
  ...svelte.configs.recommended,
  stylistic.configs.customize({
    braceStyle: '1tbs',
    jsx: false,
  }),
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        ...Object.fromEntries(Object.entries(globals.commonjs).map(([ key ]) => [ key, 'off' ])),
        app: 'writable',
        env: 'writable',
        L: 'writable',
        it: 'readonly',
        xit: 'readonly',
        describe: 'readonly',
        xdescribe: 'readonly',
        beforeEach: 'readonly',
      },

      // parser: tsParser,
      ecmaVersion: 5,
      sourceType: 'module',

      parserOptions: {
        ecmaFeatures: {
          jsx: false,
        },
        parser: ts.parser,
        projectService: {
          allowDefaultProject: [ '*.js' ],
        },
        tsconfigRootDir: import.meta.dirname,
      },
    },
    settings: {
      'import-x/resolver-next': [
        createTypeScriptImportResolver({
          project: './tsconfig.client.json',
        }),
      ],
    },

    rules: {
      // See https://eslint.org/docs/rules/
      'array-callback-return': [ 'off' ],
      'comma-dangle': [ 'error', {
        arrays: 'always-multiline',
        objects: 'always-multiline',
        imports: 'always-multiline',
        exports: 'always-multiline',
        functions: 'never',
      } ],
      eqeqeq: [ 'error', 'smart' ],
      indent: 'off',
      'implicit-arrow-linebreak': [ 'error', 'beside' ],
      'no-ex-assign': [ 'off' ],
      'no-restricted-imports': 'off',
      'no-var': [ 'error' ],
      'nonblock-statement-body-position': [ 'error', 'beside' ],
      'object-shorthand': [ 'error', 'properties' ],
      'one-var': [ 'off' ],
      'prefer-arrow-callback': [ 'error' ],
      'prefer-const': [ 'off' ],
      'prefer-rest-params': [ 'off' ],

      // See https://github.com/un-ts/eslint-plugin-import-x#rules
      'import-x/newline-after-import': 'error',
      'import-x/no-named-as-default-member': 'off',
      'import-x/order': [ 'error', {
        pathGroups: [ {
          pattern: '#*/**',
          group: 'internal',
          position: 'before',
        } ],

        groups: [ 'builtin', 'external', 'internal', 'parent', 'sibling', 'object', 'type' ],
        'newlines-between': 'never',

        alphabetize: {
          order: 'asc',
        },
      } ],

      // See https://eslint.style/rules
      '@stylistic/array-bracket-spacing': [ 'error', 'always' ],
      '@stylistic/arrow-parens': [ 'error', 'as-needed' ],
      '@stylistic/brace-style': 'error',
      '@stylistic/indent': [ 'error', 2, { MemberExpression: 'off' } ],
      '@stylistic/keyword-spacing': 'error',
      '@stylistic/member-delimiter-style': [ 'error', {
        multiline: {
          delimiter: 'none',
        },
        singleline: {
          delimiter: 'comma',
          requireLast: false,
        },
      } ],
      '@stylistic/object-curly-spacing': [ 'error', 'always' ],
      '@stylistic/space-before-function-paren': [ 'error', { anonymous: 'always', asyncArrow: 'always', named: 'always' } ],
      '@stylistic/space-infix-ops': 'error',
      '@stylistic/type-annotation-spacing': 'error',
      '@stylistic/quote-props': [ 'error', 'as-needed' ],

      // See https://typescript-eslint.io/rules/
      '@typescript-eslint/ban-ts-comment': 'off',
      '@typescript-eslint/consistent-type-imports': [ 'error', { prefer: 'type-imports' } ],
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-restricted-imports': [ 'error', {
        patterns: [ {
          group: [ '*server/' ],
          message: 'Only types can be imported from the server',
          allowTypeImports: true,
        } ],
      } ],

      // See https://sveltejs.github.io/eslint-plugin-svelte/rules/
      'svelte/no-at-html-tags': 'off',
      'svelte/no-reactive-functions': 'error',
      'svelte/no-reactive-literals': 'error',
      'svelte/no-store-async': 'error',
      'svelte/no-useless-mustaches': 'error',
      'svelte/require-optimized-style-attribute': 'error',
      'svelte/require-store-reactive-access': 'error',
      'svelte/derived-has-same-inputs-outputs': 'error',
      'svelte/first-attribute-linebreak': 'error',
      'svelte/html-closing-bracket-spacing': 'error',
      'svelte/html-quotes': 'error',
      'svelte/indent': 'error',
      'svelte/max-attributes-per-line': [ 'error', {
        multiline: 1,
        singleline: 3,
      } ],
      'svelte/mustache-spacing': 'error',
      'svelte/no-spaces-around-equal-signs-in-attribute': 'error',
      'svelte/prefer-class-directive': 'error',
      'svelte/prefer-style-directive': 'error',
      'svelte/shorthand-attribute': 'error',
      'svelte/shorthand-directive': 'error',
      'svelte/spaced-html-comment': 'error',
      'svelte/no-trailing-spaces': 'error',
      'svelte/valid-compile': 'off',
    },
  },
  {
    // See https://sveltejs.github.io/eslint-plugin-svelte/user-guide/
    files: [ '**/*.svelte', '**/*.svelte.ts', '**/*.svelte.js' ],
    languageOptions: {
      parserOptions: {
        parser: ts.parser,
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
        extraFileExtensions: [ '.svelte' ],
        svelteConfig,
      },
    },
    rules: {
      'no-return-assign': 'off',
      '@typescript-eslint/no-unused-expressions': 'off',
    },
  },
  {
    files: [ 'scripts/**' ],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
    plugins: {
      'node-import': nodeImport,
    },
    rules: {
      'node-import/prefer-node-protocol': 'error',
    },
  }
)
