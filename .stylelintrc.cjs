// This config file is used by stylelint
// See package.json scripts: lint*
// Rules documentation: https://stylelint.io/user-guide/rules/
// Inspect the generated config:
//    stylelint --print-config .
module.exports = {
  extends: [
    'stylelint-config-recommended-scss',
  ],
  rules: {
    'at-rule-no-unknown': null,
    'color-named': null,
    'declaration-colon-space-after': 'always',
    'function-no-unknown': [ true, { ignoreFunctions: [ 'lighten', 'darken' ] }],
    'function-url-no-scheme-relative': true,
    'function-url-quotes': 'always',
    indentation: 2,
    'no-descending-specificity': null,
    'no-duplicate-selectors': true,
    'scss/no-global-function-names': null,
    'selector-pseudo-class-no-unknown': [ true, { ignorePseudoClasses: 'global' } ],
    'value-keyword-case': 'lower'
  },
  overrides: [
    {
      files: [ '**/*.svelte' ],
      customSyntax: 'postcss-html'
    }
  ]
}
