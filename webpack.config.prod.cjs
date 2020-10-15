const config = require('./webpack.config.common.cjs')

// Detect when the --config argument is badly parsed by webpack (ex: --config passed *before* 'serve')
if (config.mode != null) throw new Error(`config.mode is already set: ${config.mode}`)

Object.assign(config, {
  mode: 'production',
  devtool: 'source-map',
  target: 'browserlist',
})

const js = {
  test: /\.js$/,
  exclude: /node_modules/,
  use: [
    {
      loader: 'babel-loader',
      options: {
        presets: [ '@babel/preset-env' ],
        // See https://github.com/babel/babel-loader#babel-is-injecting-helpers-into-each-file-and-bloating-my-code
        plugins: [ '@babel/plugin-transform-runtime' ],
        // See https://github.com/babel/babel-loader#babel-loader-is-slow
        cacheDirectory: true,
      }
    }
  ]
}

config.module.rules.push(js)

config.output.filename = '[name].[contenthash:8].js'

module.exports = config
