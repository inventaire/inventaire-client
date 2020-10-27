module.exports = {
  test: /\.svelte$/,
  type: 'javascript/auto',
  use: [
    {
      loader: 'svelte-loader',
      options: {
        hotReload: true,
        emitCss: true,
      },
    }
  ],
}
