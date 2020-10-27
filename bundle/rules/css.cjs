const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const postCss = require('./postcss.cjs')

module.exports = mode => {
  const rule = {
    test: /\.css$/,
    use: [
      MiniCssExtractPlugin.loader,
      'css-loader',
    ]
  }

  if (mode === 'production') rule.use.push(postCss)

  return rule
}
