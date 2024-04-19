// See https://github.com/MatthieuLemoine/unused-webpack-plugin
const path = require('node:path')
const UnusedWebpackPlugin = require('unused-webpack-plugin')

module.exports = new UnusedWebpackPlugin({
  // Source directories
  directories: [
    path.resolve(__dirname, '../../app'),
  ],
  exclude: [
    'assets/*',
    '*.d.ts',
    'tsconfig.client.json',
  ],
})
