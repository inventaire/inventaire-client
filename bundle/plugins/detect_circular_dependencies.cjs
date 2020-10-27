// See https://github.com/aackerman/circular-dependency-plugin

const CircularDependencyPlugin = require('circular-dependency-plugin')

module.exports = new CircularDependencyPlugin({
  include: /\.js$/,
  exclude: /node_modules/,
  failOnError: true,
  cwd: process.cwd(),
})
