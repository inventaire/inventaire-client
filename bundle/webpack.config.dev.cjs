const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin')
const webpackCommonConfigFactory = require('./webpack.config.common.cjs')

const mode = 'development'
const webpackConfig = webpackCommonConfigFactory(mode)

Object.assign(webpackConfig, {
  mode,
  // Override 'browserlist' value (deduced from the presence of a browserslist in package.json)
  // as that disables HMR, see https://github.com/webpack/webpack-dev-server/issues/2758
  target: 'web',
  devtool: 'eval-cheap-module-source-map',
  devServer: require('./dev_server.cjs'),
  watchOptions: {
    ignored: /node_modules/,
  },
})

// Use only in development, as types are checked by svelte-check during the pre-webpack build steps
webpackConfig.plugins.push(new ForkTsCheckerWebpackPlugin())

module.exports = webpackConfig
