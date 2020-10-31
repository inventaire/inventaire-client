const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const postCss = require('./postcss.cjs')

module.exports = mode => {
  const rule = {
    test: /\.scss$/,
  }

  if (mode === 'production') {
    rule.use = [
      MiniCssExtractPlugin.loader,
      { loader: 'css-loader', options: { importLoaders: 2 } },
      postCss,
    ]
  } else {
    rule.use = [
      { loader: 'style-loader' },
      { loader: 'css-loader', options: { importLoaders: 1 } },
    ]
  }

  rule.use.push('sass-loader')

  return rule
}
