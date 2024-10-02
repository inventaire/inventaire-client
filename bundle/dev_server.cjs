const path = require('node:path')
const { inventaireServerHost, webpackDevServer } = require('config')

module.exports = {
  host: webpackDevServer.host,
  port: webpackDevServer.port,
  hot: true,
  // See https://webpack.js.org/configuration/dev-server/#devserverproxy
  proxy: [
    {
      context: [
        '/api',
        '/public',
        '/img',
        '/local',
        '/**/*.(json|xml)',
      ],
      target: inventaireServerHost,
    },
  ],
  historyApiFallback: {
    rewrites: [
      { from: /./, to: '/public/dist/index.html' },
    ],
  },
  devMiddleware: {
    publicPath: '/public/dist/',
    stats: {
      colors: true,
      builtAt: true,
    },
  },
  client: {
    overlay: {
      errors: true,
      warnings: false,
    },
  },
  static: {
    directory: path.resolve(__dirname, '../public/dist'),
  },
}
