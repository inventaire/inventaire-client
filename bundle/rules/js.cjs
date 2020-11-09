module.exports = mode => {
  const rule = {
    test: /\.js$/,
    resolve: {
      // Allow to import modules without specifying the '.js':
      // import './foo.js' => import './foo'
      fullySpecified: false
    },
    use: []
  }

  if (mode === 'production') {
    rule.use.push(require('./babel.cjs'))
  }

  return rule
}
