const MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = {
  test: /\.css$/,
  use: [
    MiniCssExtractPlugin.loader,
    {
      // Translates CSS into CommonJS
      loader: 'css-loader',
      options: {
        sourceMap: true,
      }
    },
  ]
}
