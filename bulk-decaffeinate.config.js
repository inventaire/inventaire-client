module.exports = {
  decaffeinateArgs: [ '--loose', '--optional-chaining', '--disable-suggestion-comment' ],
  useJSModules: true,
  mochaEnvFilePattern: '^.test.js$',
  eslintPath: '~/code/inventaire/inventaire/client/node_modules/.bin/eslint',
  decaffeinatePath: '~/.nvm/versions/node/v12.18.4/bin/decaffeinate',
  numWorkers: 8
  // "skipVerify": true
}
