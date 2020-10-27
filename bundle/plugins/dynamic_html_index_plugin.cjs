const HtmlWebpackPlugin = require('html-webpack-plugin')

// See https://github.com/jantimon/html-webpack-plugin#options
module.exports = new HtmlWebpackPlugin({
  title: 'Inventaire',
  template: 'app/index.html',
  minify: false,
  showErrors: true,
})
