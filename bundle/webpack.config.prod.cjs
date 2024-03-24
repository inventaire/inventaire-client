const webpackCommonConfigFactory = require('./webpack.config.common.cjs')

const mode = 'production'
const webpackConfig = webpackCommonConfigFactory(mode)

Object.assign(webpackConfig, {
  mode,
  devtool: 'source-map',
  // Determines the target based on the browserslist set in package.json
  // Run `browserslist --update-db` from time to time to update the generated list
  target: 'browserslist',
  cache: {
    type: 'filesystem',
    profile: true,
  }
})

webpackConfig.output.filename = '[name].[contenthash:8].js'

webpackConfig.plugins.push(require('./plugins/detect_unused_files.cjs'))
webpackConfig.plugins.push(require('./plugins/bundle_analyzer.cjs'))
webpackConfig.optimization = require('./optimization.cjs')

module.exports = webpackConfig
