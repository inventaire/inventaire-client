const mode = 'production'
const config = require('./webpack.config.common.cjs')(mode)

Object.assign(config, {
  mode,
  devtool: 'source-map',
  target: 'browserslist',
})

config.output.filename = '[name].[contenthash:8].js'

config.plugins.push(require('./plugins/detect_circular_dependencies.cjs'))
config.plugins.push(require('./plugins/detect_unused_files.cjs'))
config.plugins.push(require('./plugins/bundle_analyzer.cjs'))
config.optimization = require('./optimization.cjs')

module.exports = config
