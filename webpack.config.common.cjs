// Documentation on Webpack:
// - https://webpack.js.org/concepts/
// - https://webpack.js.org/guides/
// - https://webpack.js.org/configuration/
// - https://survivejs.com/webpack/preface/

const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const { alias } = require('./package.json')

Object.keys(alias).forEach(aliasKey => {
  alias[aliasKey] = path.resolve(__dirname, alias[aliasKey])
})

const js = {
  test: /\.js$/,
  resolve: {
    // Allow to import modules without specifying the '.js':
    // import './foo.js' => import './foo'
    fullySpecified: false
  }
}

const handlebars = {
  test: /\.hbs$/,
  loader: 'handlebars-loader',
  options: {
    partialResolver: require('./resolve_handlebars_partials.cjs'),
    precompileOptions: {
      // Define helpers at runtime
      knownHelpersOnly: false,
    },
  }
}

const css = {
  test: /\.css$/,
  use: [
    {
      // Creates `style` nodes from JS strings
      loader: 'style-loader',
    },
    {
      // Translates CSS into CommonJS
      loader: 'css-loader',
      options: {
        sourceMap: true,
      }
    },
  ]
}

const scss = {
  test: /\.scss$/,
  use: [
    {
      // Creates `style` nodes from JS strings
      loader: 'style-loader',
    },
    {
      // Translates CSS into CommonJS
      loader: 'css-loader',
      options: {
        sourceMap: true,
      }
    },
    {
      // Compiles Sass to CSS
      loader: 'sass-loader',
      options: {
        sourceMap: true,
      }
    }
  ]
}

const svelte = {
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

// Recommended by https://github.com/sveltejs/svelte-loader#usage
alias.svelte = path.resolve('node_modules', 'svelte')

const images = {
  test: /\.(png|svg|jpg|gif)$/,
  use: 'file-loader',
}

const fonts = {
  test: /\.(woff|woff2|eot|ttf|otf)$/,
  use: 'file-loader',
}

const htmlIndex = new HtmlWebpackPlugin({
  // See https://github.com/jantimon/html-webpack-plugin#options
  title: 'Inventaire',
  template: 'app/index.html',
  minify: false,
  showErrors: true,
})

module.exports = {
  entry: './app/initialize.js',
  resolve: {
    alias,
    // Recommended by https://github.com/sveltejs/svelte-loader#resolvemainfields
    mainFields: [ 'svelte', 'browser', 'module', 'main' ],
  },
  plugins: [
    htmlIndex,
  ],
  output: {
    path: path.resolve(__dirname, 'public/dist'),
    filename: '[name].js',
    // Required to avoid getting assets with relative paths
    // cf https://github.com/jantimon/html-webpack-plugin/issues/98
    // https://webpack.js.org/guides/public-path/
    publicPath: '/public/dist/',
    // Might need to be turned off in production at some point
    // cf https://webpack.js.org/guides/build-performance/#output-without-path-info
    pathinfo: true,
  },
  module: {
    rules: [
      js,
      handlebars,
      css,
      scss,
      svelte,
      images,
      fonts,
    ],
  },
}
