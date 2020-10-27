const MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = {
  test: /\.css$/,
  use: [
    MiniCssExtractPlugin.loader,
    'css-loader',
  ]
}
