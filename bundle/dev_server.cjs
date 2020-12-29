const path = require('path')
const { inventaireServerHost, webpackDevServer } = require('config')

module.exports = {
  host: webpackDevServer.host,
  port: webpackDevServer.port,
  contentBase: path.resolve(__dirname, '../public/dist'),
  publicPath: '/public/dist/',
  hot: true,
  overlay: true,
  // See https://webpack.js.org/configuration/dev-server/#devserverproxy
  proxy: {
    '/api': inventaireServerHost,
    '/public': inventaireServerHost,
    '/img': inventaireServerHost,
    '/**/*.(json|xml)': inventaireServerHost,
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
