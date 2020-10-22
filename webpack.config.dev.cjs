const config = require('./webpack.config.common.cjs')
const CircularDependencyPlugin = require('circular-dependency-plugin')
const path = require('path')

// Detect when the --config argument is badly parsed by webpack (ex: --config passed *before* 'serve')
if (config.mode != null) throw new Error(`config.mode is already set: ${config.mode}`)

Object.assign(config, {
  mode: 'development',
  // Override 'browserlist' value (deduced from the presence of a browserslist in package.json)
  // as that disables HMR, see https://github.com/webpack/webpack-dev-server/issues/2758
  target: 'web',
  devtool: 'eval-cheap-module-source-map',
  devServer: {
    host: '0.0.0.0',
    port: 3005,
    contentBase: path.resolve(__dirname, 'public/dist'),
    publicPath: '/public/dist/',
    hot: true,
    overlay: true,
    // See https://webpack.js.org/configuration/dev-server/#devserverproxy
    proxy: {
      '/api': 'http://localhost:3006',
      '/public': 'http://localhost:3006',
      '/img': 'http://localhost:3006',
    },
    historyApiFallback: {
      rewrites: [
        { from: /./, to: '/public/dist/index.html' },
      ]
    },
  }
})

config.plugins.push(new CircularDependencyPlugin({
  include: /\.js$/,
  exclude: /node_modules/,
  failOnError: true,
  cwd: process.cwd(),
}))

module.exports = config
