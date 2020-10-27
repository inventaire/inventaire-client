const MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = {
  test: /\.scss$/,
  use: [
    MiniCssExtractPlugin.loader,
    {
      // Translates CSS into CommonJS
      loader: 'css-loader',
      options: {
        sourceMap: true,
      }
    },
    {
      // Compiles Sass to CSS
      loader: 'sass-loader',
      options: {
        sourceMap: true,
      }
    }
  ]
}
