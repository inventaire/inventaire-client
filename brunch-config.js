exports.config =
  # See http://brunch.io/docs/getting-started for docs.
  sourceMaps: true
  paths:
    # doc: https://github.com/brunch/brunch/blob/master/docs/config.md#paths
    watched: ['app', 'vendor']
  files:
    javascripts:
      joinTo:
        'js/vendor.js': /^(vendor\/js|node_modules)/
        'js/app.js': /^app/

    stylesheets:
      joinTo:
        'css/vendor.css': /^vendor\/css/
        'css/app.css': /^app/

    templates:
      joinTo: 'js/app.js'

  plugins:
    autoReload:
      enabled: true
    afterBrunch: [
      './scripts/check_empty_files'
    ]
  overrides:
    production:
      sourceMaps: true
      optimize: true
      plugins:
        autoReload:
          enabled: false
        postcss:
          processors: [
            require('autoprefixer')(['> 1%', 'last 3 versions']),
          ]
