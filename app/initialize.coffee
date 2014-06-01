require('lib/view-helper')()
app = app || {}
app.AppView = require "views/app_view"
app.Router = require "./router"

app.config =
  title: "Inventaire"


# app.ContactBook = require "collections/contacts"

# # Initialize the application on DOM ready event.
$ ->
  # app.Contacts = new app.ContactBook()
  app.MainView = new app.AppView
  app.MainView.render()
  app.Router = new app.Router
  Backbone.history.start({pushState: true})
  return