module.exports = {
  loader: 'postcss-loader',
  options: {
    postcssOptions: {
      plugins: [
        'postcss-preset-env',
      ]
    }
  }
}
