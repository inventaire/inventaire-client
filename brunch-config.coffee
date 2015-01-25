exports.config =
  # See http://brunch.io/#documentation for docs.
  notifications: yes
  sourceMaps: true
  files:
    javascripts:
      defaultExtension: "coffee"
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(vendor\/scripts|bower_components)/
      order:
        before: [
          "bower_components/jquery/dist/jquery.js"
          "bower_components/underscore/underscore.js"
          "bower_components/backbone/backbone.js"
        ],
        after: [
          "vendor/*"
        ]

    stylesheets:
      defaultExtension: "scss"
      joinTo:
        'stylesheets/app.css': /^(app)/
        # excluding foundation as its scss files are selected from the app
        'stylesheets/vendor.css': /^(vendor\/stylesheets|bower_components\/(?!foundation))/

    templates:
      joinTo: 'javascripts/app.js'
  plugins:
    autoReload:
      enabled: true
  # modules:
  #   nameCleaner: (path) ->
  #     path.replace /.*app\//, ''
  overrides:
    production:
      sourceMaps: false
      optimize: true
      plugins: autoReload: enabled: false