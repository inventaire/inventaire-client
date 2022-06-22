// Deduce the core-js version to use from the version installed
// to pickup new feature versions automatically
const coreJsVersion = require('core-js/package.json').version.split('.').slice(0, 2).join('.')
if (coreJsVersion.split('.')[0] !== '3') {
  throw new Error('Expected core-js 3.x to be installed')
}

module.exports = {
  loader: 'babel-loader',
  options: {
    // Only transpile modules that need it
    // See https://stackoverflow.com/questions/54156617/why-would-we-exclude-node-modules-when-using-babel-loader
    // and https://github.com/babel/babel-loader/issues/171
    exclude: /node_modules\/(?!(svelte))/,
    presets: [
      [
        // Relies on browserslist to determine how far back in ECMAscript versions babel should go
        '@babel/preset-env',
        {
          corejs: { version: coreJsVersion },
          // Add polyfills per module, based on usage
          // See https://babeljs.io/docs/en/babel-preset-env#usebuiltins
          useBuiltIns: 'usage',
          // Allows to use features that are still at the proposal stage
          // but already implemented by some browsers
          // See https://babeljs.io/docs/en/babel-preset-env#shippedproposals
          shippedProposals: true,
          // See https://babeljs.io/docs/en/babel-preset-env#bugfixes
          bugfixes: true,
          // Uncomment to get the list of polyfills included in build logs
          // debug: true,
        }
      ]
    ],
    // Requires @babel/runtime
    // See https://github.com/babel/babel-loader#babel-is-injecting-helpers-into-each-file-and-bloating-my-code
    plugins: [ '@babel/plugin-transform-runtime' ],
    // See https://github.com/babel/babel-loader#babel-loader-is-slow
    cacheDirectory: true,
    // See https://babeljs.io/docs/en/assumptions
    assumptions: {
      noDocumentAll: true,
      noNewArrows: true,
    }
  }
}
