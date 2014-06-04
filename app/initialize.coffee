require('lib/hbs_partial_helper')()

AppView = require "views/app_view"
Router = require "./router"

# Initialize the application on DOM ready event.
$ ->

  # initialize foundation
  $(document).foundation()

  appView = new AppView
  appView.render()
  router = new Router
  Backbone.history.start({pushState: true})
  return