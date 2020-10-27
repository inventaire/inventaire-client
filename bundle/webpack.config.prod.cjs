const config = require('./webpack.config.common.cjs')

// Detect when the --config argument is badly parsed by webpack (ex: --config passed *before* 'serve')
if (config.mode != null) throw new Error(`config.mode is already set: ${config.mode}`)

Object.assign(config, {
  mode: 'production',
  devtool: 'source-map',
  target: 'browserslist',
})

config.output.filename = '[name].[contenthash:8].js'

config.module.rules.push(require('./rules/babel.cjs'))
config.plugins.push(require('./plugins/bundle_analyzer.cjs'))
config.optimization = require('./optimization.cjs')

module.exports = config
