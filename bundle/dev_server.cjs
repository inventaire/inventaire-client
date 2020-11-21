const path = require('path')
const { inventaireServerHost } = require('config')

module.exports = {
  host: '0.0.0.0',
  port: 3005,
  contentBase: path.resolve(__dirname, '../public/dist'),
  publicPath: '/public/dist/',
  hot: true,
  overlay: true,
  // See https://webpack.js.org/configuration/dev-server/#devserverproxy
  proxy: {
    '/api': inventaireServerHost,
    '/public': inventaireServerHost,
    '/img': inventaireServerHost,
  },
  historyApiFallback: {
    rewrites: [
      { from: /./, to: '/public/dist/index.html' },
    ]
  },

  stats: {
    colors: true,
    builtAt: true,
  },
}
