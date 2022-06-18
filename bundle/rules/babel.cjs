module.exports = {
  loader: 'babel-loader',
  options: {
    // Required to avoid errors such as:
    // "export 'default' (imported as '_') was not found in 'underscore' (possible exports: )"
    exclude: /node_modules/,
    presets: [ '@babel/preset-env' ],
    // Requires @babel/runtime
    // See https://github.com/babel/babel-loader#babel-is-injecting-helpers-into-each-file-and-bloating-my-code
    plugins: [ '@babel/plugin-transform-runtime' ],
    // See https://github.com/babel/babel-loader#babel-loader-is-slow
    cacheDirectory: true,
  }
}
