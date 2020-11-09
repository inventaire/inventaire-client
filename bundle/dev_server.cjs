const path = require('path')

module.exports = {
  host: '0.0.0.0',
  port: 3005,
  contentBase: path.resolve(__dirname, '../public/dist'),
  publicPath: '/public/dist/',
  hot: true,
  overlay: true,
  // See https://webpack.js.org/configuration/dev-server/#devserverproxy
  proxy: {
    '/api': 'http://localhost:3006',
    '/public': 'http://localhost:3006',
    '/img': 'http://localhost:3006',
  },
  historyApiFallback: {
    rewrites: [
      { from: /./, to: '/public/dist/index.html' },
    ]
  },
}
