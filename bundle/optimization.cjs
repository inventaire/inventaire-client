// See https://webpack.js.org/configuration/optimization/

module.exports = {
  moduleIds: 'named',
  chunkIds: 'named',
  // See https://webpack.js.org/configuration/optimization/#optimizationminimizer
  minimizer: [
    require('./terser.cjs')
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
