// See https://webpack.js.org/configuration/optimization/

module.exports = {
  moduleIds: 'named',
  chunkIds: 'named',
  // Uncomment to inspect unminified bundled code
  // minimize: false,
  // See https://webpack.js.org/configuration/optimization/#optimizationminimizer
  minimizer: [
    require('./terser.cjs'),
  ],
  // See https://webpack.js.org/guides/build-performance/#minimal-entry-chunk
  runtimeChunk: {
    name: 'runtime',
  },
  // See https://webpack.js.org/guides/caching/
  splitChunks: {
    cacheGroups: {
      vendor: {
        test: /[\\/](node_modules|vendor)[\\/](underscore|fork-awesome|node-polyglot|regenerator-runtime|wikidata-lang|autosize|@babel|define-properties|css-loader|js-cookie|p-|leven)/,
        name: 'vendor',
        chunks: 'all',
      },
      // Making a separate bundle as this is bundle is more likely to change than the libs above
      // Ex: when browsers are removed from the browserslist-generated list of supported browsers
      // some polyfills might be removed from this bundle
      polyfills: {
        test: /[\\/]node_modules[\\/]core-js/,
        name: 'polyfills',
        chunks: 'all',
      },
      leaflet: {
        test: /[\\/]node_modules[\\/]leaflet/,
        name: 'leaflet',
        chunks: 'all',
      },
    },
  },
}
