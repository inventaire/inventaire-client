const { sass } = require('svelte-preprocess-sass')
const { alias } = require('../resolve.cjs')

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
                importer: [
                  resolveScssAlias,
                ],
              })
            }
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

// Inspired by https://github.com/sveltejs/svelte-preprocess/issues/97#issuecomment-551842456
const resolveScssAlias = path => {
  if (path[0] !== '#') return path
  const segment = path.split('/')[0]
  return {
    file: path.replace(segment, alias[segment])
  }
}
