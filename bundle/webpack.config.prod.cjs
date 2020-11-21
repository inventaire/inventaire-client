const mode = 'production'
const webpackConfig = require('./webpack.config.common.cjs')(mode)

Object.assign(webpackConfig, {
  mode,
  devtool: 'source-map',
  target: 'browserslist',
})

webpackConfig.output.filename = '[name].[contenthash:8].js'

webpackConfig.plugins.push(require('./plugins/detect_circular_dependencies.cjs'))
webpackConfig.plugins.push(require('./plugins/detect_unused_files.cjs'))
webpackConfig.plugins.push(require('./plugins/bundle_analyzer.cjs'))
webpackConfig.optimization = require('./optimization.cjs')

module.exports = webpackConfig
