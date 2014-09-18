exports.config =
  # See http://brunch.io/#documentation for docs.
  notifications: yes
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
        'stylesheets/vendor.css': /^(vendor)/

    templates:
      joinTo: 'javascripts/app.js'
