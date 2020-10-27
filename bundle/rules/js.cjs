module.exports = {
  test: /\.js$/,
  resolve: {
    // Allow to import modules without specifying the '.js':
    // import './foo.js' => import './foo'
    fullySpecified: false
  }
}
