require('lib/handlebars_partial_helper')()
app = require 'app'

_.extend _, require 'lib/utils'

#changing the default attribute to fit CouchDB
Backbone.Model.prototype.idAttribute = '_id'

# Initialize the application on DOM ready event.
$ ->
  app.initialize()
  window.app = app
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


