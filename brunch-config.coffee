exports.config =
  # See http://brunch.io/#documentation for docs.
  notifications: yes
  files:
    javascripts:
      defaultExtension: "coffee"
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(?!app)/

    stylesheets:
      defaultExtension: "scss"
      joinTo: 'stylesheets/app.css'

    templates:
      joinTo: 'javascripts/app.js'
