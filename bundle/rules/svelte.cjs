const { sass } = require('svelte-preprocess-sass')

module.exports = mode => {
  return [
    {
      test: /\.svelte$/,
      type: 'javascript/auto',
      use: [
        {
          loader: 'svelte-loader',
          options: {
            compilerOptions: {
              dev: mode !== 'production',
            },
            hotReload: mode !== 'production',
            // Only emit in production to get the page to reload on style change in development
            emitCss: mode === 'production',
            preprocess: {
              style: sass({
                includePaths: [ 'node_modules' ]
              })
            },
          },
        }
      ],
    },
    {
      // Required to prevent errors from Svelte on Webpack 5+
      // as recommended by https://github.com/sveltejs/svelte-loader#usage
      test: /node_modules\/svelte\/.*\.mjs$/,
      resolve: {
        fullySpecified: false
      }
    }
  ]
}
