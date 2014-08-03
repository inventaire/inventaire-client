require('lib/handlebars_helpers').initialize()
app = require 'app'

_.extend _, require 'lib/utils'

#changing the default attribute to fit CouchDB
Backbone.Model.prototype.idAttribute = '_id'

Backbone.Marionette.View.prototype.addMultipleSelectorEvents = ->
  # expects multipleSelectorEvents to be an array of triples:
  # [[event, [selector, ..], handler], ..]
  if @multipleSelectorEvents?
    @multipleSelectorEvents.forEach (multipleEventsArray)=>
        multipleEventsArray[1].forEach (selector)=>
          @events["#{multipleEventsArray[0]} #{selector}"] = multipleEventsArray[2]

# Initialize the application on DOM ready event.
$ ->
  app.initialize()
  window.app = app

  # gets all the routes used in the app
  app.API = require 'api'

  # makes all the require's accessible from app
  # might be dramatically heavy from start though
  # -> should be refactored to make them functions called at run-time?
  _.extend app, require 'structure'
  app.Lib.EventLogger.call app

  app.layout = new app.Layout.App

  app.module 'foundation', app.Module.Foundation(app.Foundation, app, Backbone, Marionette, $, _)

  app.module 'user', app.Module.User(app.user, app, Backbone, Marionette, $, _)
  if app.user.loggedIn
    app.module 'contacts', app.Module.Contacts(app.Contacts, app, Backbone, Marionette, $, _)
    app.module 'inventory', app.Module.Inventory(app.Inventory, app, Backbone, Marionette, $, _)
  else
    welcome = new app.View.Welcome
    app.layout.main.show welcome
