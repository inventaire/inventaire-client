// About using SCSS in Svelte components: it can work by adding a preprocessor such as
// https://github.com/ls-age/svelte-preprocess-sass
// but then style hot reload is broken
// See also https://daveceddia.com/svelte-with-sass-in-vscode/

module.exports = mode => ({
  test: /\.svelte$/,
  type: 'javascript/auto',
  use: [
    {
      loader: 'svelte-loader',
      options: {
        hotReload: true,
        // Only emit in production to get the page to reload on style change in development
        emitCss: mode === 'production',
      },
    }
  ],
})
