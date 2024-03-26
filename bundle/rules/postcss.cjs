const postcssPresetEnv = require('postcss-preset-env')()
// eslint-disable-next-line import/order
const cssnano = require('cssnano')({
  preset: [
    'default',
    {
      discardComments: {
        removeAll: true,
      },
    },
  ],
})

module.exports = {
  loader: 'postcss-loader',
  options: {
    postcssOptions: {
      plugins: [
        postcssPresetEnv,
        cssnano,
      ],
    },
  },
}
