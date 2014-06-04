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
      #   after: [
      #     "bower_components/backbone/backbone.js"
      #     "bower_components/Backbone.localStorage/backbone.localStorage.js"
      #     "bower_components/backbone-forms/distribution/backbone-forms.js"
      #   ]
      # can't make it work so the scripts that have to be after
      # are copied from bower_components to vendor and then removed
      # from bower_compenents

    stylesheets:
      defaultExtension: "scss"
      joinTo:
        'stylesheets/app.css': /^(app)/
        'stylesheets/vendor.css': /^(vendor)/

    templates:
      joinTo: 'javascripts/app.js'
