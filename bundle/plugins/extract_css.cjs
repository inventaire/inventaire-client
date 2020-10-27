const MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = new MiniCssExtractPlugin({
  filename: '[name].[contenthash:8].css'
})
