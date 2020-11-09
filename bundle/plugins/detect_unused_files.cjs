// See https://github.com/MatthieuLemoine/unused-webpack-plugin
const UnusedWebpackPlugin = require('unused-webpack-plugin')
const path = require('path')

module.exports = new UnusedWebpackPlugin({
  // Source directories
  directories: [
    path.resolve(__dirname, '../../app')
  ],
  exclude: [
    'assets/*'
  ],
})
