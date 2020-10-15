const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const { CleanWebpackPlugin } = require('clean-webpack-plugin')
const { ProvidePlugin } = require('webpack')
const { alias } = require('./package.json')

Object.keys(alias).forEach(aliasKey => {
  alias[aliasKey] = path.resolve(__dirname, alias[aliasKey])
})

const js = {
  test: /\.js$/,
  resolve: {
    // Allow to import modules without specifying the '.js':
    // import './foo.js' => import './foo'
    fullySpecified: false
  }
}

const handlebars = {
  test: /\.hbs$/,
  loader: 'handlebars-loader',
  options: {
    partialResolver: require('./resolve_handlebars_partials.cjs'),
    precompileOptions: {
      // Define helpers at runtime
      knownHelpersOnly: false,
    },
  }
}

const css = {
  test: /\.css$/,
  use: [
    {
      // Creates `style` nodes from JS strings
      loader: 'style-loader',
    },
    {
      // Translates CSS into CommonJS
      loader: 'css-loader',
      options: {
        sourceMap: true,
      }
    },
  ]
}

const scss = {
  test: /\.scss$/,
  use: [
    {
      // Creates `style` nodes from JS strings
      loader: 'style-loader',
    },
    {
      // Translates CSS into CommonJS
      loader: 'css-loader',
      options: {
        sourceMap: true,
      }
    },
    {
      // Compiles Sass to CSS
      loader: 'sass-loader',
      options: {
        sourceMap: true,
      }
    }
  ]
}

const images = {
  test: /\.(png|svg|jpg|gif)$/,
  use: [
    'file-loader',
  ]
}

const fonts = {
  test: /\.(woff|woff2|eot|ttf|otf)$/,
  use: [
    'file-loader',
  ]
}

const htmlIndex = new HtmlWebpackPlugin({
  // See https://github.com/jantimon/html-webpack-plugin#options
  title: 'Inventaire',
  template: 'app/index.html',
  minify: false,
  showErrors: true,
})

// See https://webpack.js.org/guides/shimming/#shimming-globals
// See also https://gitlab.com/foodsharing-dev/foodsharing/-/blob/master/client/shims.js
// https://webpack.js.org/loaders/imports-loader/
const importGlobals = new ProvidePlugin({
  $: 'jquery',
  'window.$': 'jquery',
  jQuery: 'jquery',
  'window.jQuery': 'jquery',
  Backbone: 'backbone',
  'window.Backbone': 'backbone',
  _: 'underscore',
  Marionette: 'backbone.marionette',
  FilteredCollection: 'backbone-filtered-collection',
  // NestedModel: 'backbone-nested',
})

module.exports = {
  entry: './app/initialize.js',
  resolve: {
    alias,
  },
  plugins: [
    new CleanWebpackPlugin({ cleanStaleWebpackAssets: false }),
    htmlIndex,
    importGlobals
  ],
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: '[name].js'
  },
  module: {
    rules: [
      js,
      handlebars,
      css,
      scss,
      images,
      fonts,
    ],
  },

  // optimization: {
  //   // See https://webpack.js.org/guides/build-performance/#minimal-entry-chunk
  //   runtimeChunk: true,
  //   // See https://webpack.js.org/guides/caching/
  //   splitChunks: {
  //     cacheGroups: {
  //       commons: {
  //         test: /[\\/]node_modules[\\/](backbone|underscore|jquery|handlebars|babel)/,
  //         name: 'vendors',
  //         chunks: 'all'
  //       }
  //     }
  //   }
  // }
}
