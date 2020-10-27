// Documentation on Webpack:
// - https://webpack.js.org/concepts/
// - https://webpack.js.org/guides/
// - https://webpack.js.org/configuration/
// - https://survivejs.com/webpack/preface/

const path = require('path')

module.exports = mode => ({
  entry: './app/initialize.js',
  resolve: require('./resolve.cjs'),
  plugins: [
    require('./plugins/extract_css.cjs'),
    require('./plugins/dynamic_html_index_plugin.cjs'),
  ],
  output: {
    path: path.resolve(__dirname, '../public/dist'),
    filename: '[name].js',
    // Required to avoid getting assets with relative paths
    // cf https://github.com/jantimon/html-webpack-plugin/issues/98
    // https://webpack.js.org/guides/public-path/
    publicPath: '/public/dist/',
    // Might need to be turned off in production at some point
    // cf https://webpack.js.org/guides/build-performance/#output-without-path-info
    pathinfo: true,
  },
  module: {
    rules: [
      require('./rules/js.cjs')(mode),
      require('./rules/css.cjs')(mode),
      require('./rules/scss.cjs')(mode),
      require('./rules/handlebars.cjs'),
      require('./rules/svelte.cjs'),
      require('./rules/images.cjs'),
      require('./rules/fonts.cjs'),
    ],
  },
})
