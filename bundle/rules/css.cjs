const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const postCss = require('./postcss.cjs')

module.exports = mode => {
  const rule = {
    test: /\.css$/
  }

  if (mode === 'production') {
    rule.use = [
      MiniCssExtractPlugin.loader,
      { loader: 'css-loader', options: { importLoaders: 1 } },
      postCss,
    ]
  } else {
    rule.use = [
      { loader: 'style-loader' },
      { loader: 'css-loader', options: { importLoaders: 0 } },
    ]
  }

  return rule
}
