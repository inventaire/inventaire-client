const MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = new MiniCssExtractPlugin({
  filename: '[name].[contenthash:8].css',
  chunkFilename: '[name].[contenthash:8].css',
  // See https://github.com/webpack-contrib/mini-css-extract-plugin#ignoreOrder
  ignoreOrder: true,
})
