module.exports = {
  loader: 'babel-loader',
  options: {
    // Only transpile modules that need it
    // See https://stackoverflow.com/questions/54156617/why-would-we-exclude-node-modules-when-using-babel-loader
    // and https://github.com/babel/babel-loader/issues/171
    exclude: /node_modules\/(?!(svelte))/,
    presets: [ '@babel/preset-env' ],
    // Requires @babel/runtime
    // See https://github.com/babel/babel-loader#babel-is-injecting-helpers-into-each-file-and-bloating-my-code
    plugins: [ '@babel/plugin-transform-runtime' ],
    // See https://github.com/babel/babel-loader#babel-loader-is-slow
    cacheDirectory: true,
  }
}
