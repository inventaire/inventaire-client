app = app || {}

app.ContactBook = require "collections/contacts"
app.AppView = require "views/app_view"
app.Router = require "./router"

# # Initialize the application on DOM ready event.
$ ->
  app.Contacts = new app.ContactBook()
  app.MainView = new app.AppView(app.Contacts)
  app.Router = new app.ApplicationRouter()
  Backbone.history.start({pushState: true})
  return