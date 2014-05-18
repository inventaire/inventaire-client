exports.config =
  # See http://brunch.io/#documentation for docs.
  notifications: no
  files:
    javascripts:
      defaultExtension: "coffee"
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(?!app)/
      # order:
      #   before: ["bower_components/backbone/backbone.js"]
      #   after: ["bower_components/Backbone.localStorage/backbone.localStorage.js"]
      # order not working

    stylesheets:
      defaultExtension: "scss"
      joinTo: 'stylesheets/app.css'

    templates:
      joinTo: 'javascripts/app.js'
