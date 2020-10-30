const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const postCss = require('./postcss.cjs')

module.exports = mode => {
  const rule = {
    test: /\.css$/,
    use: [
      MiniCssExtractPlugin.loader,
    ]
  }

  if (mode === 'production') {
    rule.use.push({ loader: 'css-loader', options: { importLoaders: 1 } })
    rule.use.push(postCss)
  } else {
    rule.use.push({ loader: 'css-loader', options: { importLoaders: 0 } })
  }

  return rule
}
