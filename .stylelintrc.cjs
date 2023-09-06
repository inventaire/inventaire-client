// This config file is used by stylelint
// See package.json scripts: lint*
// Rules documentation: https://stylelint.io/user-guide/rules/
// Inspect the generated config (passing some path is required):
//    stylelint --print-config ./app
module.exports = {
  extends: [
    'stylelint-config-standard-scss',
  ],
  plugins: [
    'stylelint-use-logical',
  ],
  rules: {
    'at-rule-empty-line-before': null,
    'at-rule-no-unknown': null,
    'block-opening-brace-newline-after': 'always-multi-line',
    'block-opening-brace-space-before': 'never',
    'color-hex-case': 'lower',
    // Disabled to prevent errors on scss rgba implementation
    // See https://github.com/stylelint/stylelint/issues/5671
    'color-function-notation': null,
    'color-named': null,
    'comment-empty-line-before': null,
    // See https://github.com/csstools/stylelint-use-logical
    'csstools/use-logical': [
      'always',
      {
        // Excluding properties for which there is no current known use-case
        except: [ 'width', 'min-width', 'max-width', 'height', 'min-height', 'max-height' ]
      }
    ],
    'declaration-block-no-redundant-longhand-properties': null,
    'declaration-colon-space-after': 'always',
    'declaration-empty-line-before': null,
    'function-no-unknown': [ true, { ignoreFunctions: [ 'lighten', 'darken' ] }],
    'function-url-no-scheme-relative': true,
    'function-url-quotes': 'always',
    indentation: 2,
    'no-descending-specificity': null,
    'no-duplicate-selectors': true,
    'rule-empty-line-before': null,
    'scss/dollar-variable-empty-line-before': null,
    'scss/double-slash-comment-empty-line-before': null,
    'scss/no-global-function-names': null,
    'selector-class-pattern': null,
    'selector-id-pattern': null,
    'selector-list-comma-newline-after': null,
    'selector-pseudo-class-no-unknown': [ true, { ignorePseudoClasses: 'global' } ],
    'value-keyword-case': 'lower',
  },
  overrides: [
    {
      files: [ '**/*.svelte' ],
      customSyntax: 'postcss-html'
    }
  ],
  // Some rules will be removed in future versions of Stylelint,
  // see https://stylelint.io/migration-guide/to-15
  // Unfortunately, this flag seems to be ignored by the CLI
  quietDeprecationWarnings: true
}
