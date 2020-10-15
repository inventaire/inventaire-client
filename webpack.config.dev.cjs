const config = require('./webpack.config.common.cjs')

// Detect when the --config argument is badly parsed by webpack (ex: --config passed *before* 'serve')
if (config.mode != null) throw new Error(`config.mode is already set: ${config.mode}`)

const port = 3005

Object.assign(config, {
  mode: 'development',
  // Override 'browserlist' value (deduced from the presence of a browserslist in package.json)
  // as that disables HMR, see https://github.com/webpack/webpack-dev-server/issues/2758
  target: 'web',
  devtool: 'eval-cheap-module-source-map',
  devServer: {
    contentBase: './dist',
    port,
    hot: true,
    overlay: true,
    // See https://webpack.js.org/configuration/dev-server/#devserverproxy
    proxy: {
      '/api': 'http://localhost:3006',
      '/public': 'http://localhost:3006',
      '/img': 'http://localhost:3006',
    },
  }
})

module.exports = config
