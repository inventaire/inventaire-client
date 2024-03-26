module.exports = {
  test: /\.hbs$/,
  loader: 'handlebars-loader',
  options: {
    partialResolver: require('./resolve_handlebars_partials.cjs'),
    precompileOptions: {
      // Define helpers at runtime
      knownHelpersOnly: false,
    },
  },
}
