module.exports = mode => {
  const rule = {
    test: /\.ts$/,
    resolve: {
      // Allow to import modules without specifying the '.js':
      // import './foo.js' => import './foo'
      // fullySpecified: false,
    },
  }

  rule.use = [ require('./babel.cjs')(mode) ]

  return rule
}
