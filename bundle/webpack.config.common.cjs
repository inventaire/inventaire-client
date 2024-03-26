// Documentation on Webpack:
// - https://webpack.js.org/concepts/
// - https://webpack.js.org/guides/
// - https://webpack.js.org/configuration/
// - https://survivejs.com/webpack/preface/

const path = require('node:path')
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin')

module.exports = mode => ({
  entry: './app/initialize.ts',
  resolve: require('./resolve.cjs'),
  plugins: [
    require('./plugins/extract_css.cjs'),
    require('./plugins/dynamic_html_index_plugin.cjs'),
    require('./plugins/detect_circular_dependencies.cjs'),
    require('./plugins/detect_unused_files.cjs'),
    new ForkTsCheckerWebpackPlugin(),
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
      require('./rules/ts.cjs')(mode),
      require('./rules/css.cjs')(mode),
      require('./rules/scss.cjs')(mode),
      require('./rules/handlebars.cjs'),
      ...require('./rules/svelte.cjs')(mode),
      require('./rules/images.cjs'),
      require('./rules/fonts.cjs'),
    ],
  },
})
