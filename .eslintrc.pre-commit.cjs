// This config file is used by pre-commit hooks
// See package.json script lint-pre-commit

module.exports = {
  extends: [
    // Helps to spot unsupported features that woul result in
    // babel including the corresponding core-js polyfills
    // in the bundle served to all users
    // See https://github.com/amilajack/eslint-plugin-compat
    // NB: some unsupported features are unfortunately not detected
    // Ex: Array methods https://github.com/amilajack/eslint-plugin-compat/issues/258
    'plugin:compat/recommended',
  ],
  settings: {
    // Used by eslint-plugin-compat
    polyfills: [
      'Promise',
    ],
  },
}
