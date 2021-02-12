const HtmlWebpackPlugin = require('html-webpack-plugin')

// See https://github.com/jantimon/html-webpack-plugin#options
module.exports = new HtmlWebpackPlugin({
  title: 'Inventaire',
  template: 'app/index.html',
  minify: {
    // See https://github.com/terser/html-minifier-terser#options-quick-reference
    removeComments: true,
  },
  showErrors: true,
})
