exports.config =
  # See http://brunch.io/#documentation for docs.
  notifications: true
  sourceMaps: true
  paths:
    # doc: https://github.com/brunch/brunch/blob/master/docs/config.md#paths
    watched: ['app', 'vendor']
  files:
    javascripts:
      joinTo:
        # foundation js is included in vendor as a normal bower component
        'js/vendor.js': /^(vendor\/js|bower_components|node_modules)/
        'js/app.js': /^app/
      order:
        before: [
          "bower_components/jquery/dist/jquery.js"
          "bower_components/underscore/underscore.js"
          "bower_components/backbone/backbone.js"
        ],
        after: [
          "bower_components/leaflet.markercluster/dist/leaflet.markercluster-src.js"
          "vendor/*"
        ]

    stylesheets:
      joinTo:
        # /!\ foundation is joined to app.css as its scss '!default'ed properties requires to be after app
        # but in the same compiled file! (thus the failing attemps to extract foundation in its own file)
        'css/vendor.css': /^(vendor\/css|bower_components\/(?!foundation))/
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
