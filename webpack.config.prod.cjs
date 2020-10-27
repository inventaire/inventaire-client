const config = require('./webpack.config.common.cjs')
const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer')
const TerserPlugin = require('terser-webpack-plugin')

// Detect when the --config argument is badly parsed by webpack (ex: --config passed *before* 'serve')
if (config.mode != null) throw new Error(`config.mode is already set: ${config.mode}`)

Object.assign(config, {
  mode: 'production',
  devtool: 'source-map',
  target: 'browserslist',
})

const js = {
  test: /\.js$/,
  // Required to avoid errors such as:
  // "export 'default' (imported as '_') was not found in 'underscore' (possible exports: )"
  exclude: /node_modules/,
  use: [
    {
      loader: 'babel-loader',
      options: {
        presets: [ '@babel/preset-env' ],
        // See https://github.com/babel/babel-loader#babel-is-injecting-helpers-into-each-file-and-bloating-my-code
        plugins: [ '@babel/plugin-transform-runtime' ],
        // See https://github.com/babel/babel-loader#babel-loader-is-slow
        cacheDirectory: true,
      }
    }
  ]
}

config.module.rules.push(js)

config.output.filename = '[name].[contenthash:8].js'

// See https://webpack.js.org/configuration/optimization/
config.optimization = {
  moduleIds: 'named',
  chunkIds: 'named',
  // See https://webpack.js.org/configuration/optimization/#optimizationminimizer
  minimizer: [
    new TerserPlugin({
      extractComments: false,
      terserOptions: {
        output: {
          comments: false
        }
      },
    })
  ],
  // See https://webpack.js.org/guides/build-performance/#minimal-entry-chunk
  runtimeChunk: {
    name: 'runtime'
  },
  // See https://webpack.js.org/guides/caching/
  splitChunks: {
    cacheGroups: {
      vendor: {
        test: /[\\/](node_modules|vendor)[\\/](backbone|underscore|jquery|handlebars|fork-awesome|node-polyglot|regenerator-runtime|wikidata-lang|autosize|@babel|define-properties|css-loader|js-cookie|p-|leven)/,
        name: 'vendor',
        chunks: 'all'
      },
      leaflet: {
        test: /[\\/]node_modules[\\/]leaflet/,
        name: 'leaflet',
        chunks: 'all'
      },
    },
  }
}

config.plugins.push(new BundleAnalyzerPlugin({
  analyzerMode: 'static',
  reportFilename: 'bundle_report.html',
  generateStatsFile: true,
  statsFilename: 'bundle_stats.json',
  openAnalyzer: false,
}))

module.exports = config
