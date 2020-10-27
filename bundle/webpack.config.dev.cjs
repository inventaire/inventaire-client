const config = require('./webpack.config.common.cjs')

// Detect when the --config argument is badly parsed by webpack (ex: --config passed *before* 'serve')
if (config.mode != null) throw new Error(`config.mode is already set: ${config.mode}`)

Object.assign(config, {
  mode: 'development',
  // Override 'browserlist' value (deduced from the presence of a browserslist in package.json)
  // as that disables HMR, see https://github.com/webpack/webpack-dev-server/issues/2758
  target: 'web',
  devtool: 'eval-cheap-module-source-map',
  devServer: require('./dev_server.cjs')
})

config.plugins.push(require('./plugins/detect_circular_dependencies.cjs'))

module.exports = config
