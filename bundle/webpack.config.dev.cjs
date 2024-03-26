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

module.exports = webpackConfig
