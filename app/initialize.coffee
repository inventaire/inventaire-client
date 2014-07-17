require('lib/handlebars_partial_helper')()
app = require 'app'

# #changing the default attribute to fit CouchDB
Backbone.Model.prototype.idAttribute = '_id'

# Initialize the application on DOM ready event.
$ ->
  app.initialize()
  window.app = app

  app.commands.setHandler 'modal:open', ->
    $('#modal').foundation('reveal', 'open')
  app.commands.setHandler 'modal:close', ->
    $('#modal').foundation('reveal', 'close')
    # next line is commented-out as it produce an error: can't find #modalContent once closed once
    # app.layout.modal.reset()

  if app.user.loggedIn
    app.Contacts = app.module 'contacts', app.Module.Contacts(app.Contacts, app, Backbone, Marionette, $, _)
    app.Inventory = app.module 'inventory', app.Module.Inventory(app.Inventory, app, Backbone, Marionette, $, _)
  else
    welcome = new app.View.Welcome
    app.layout.main.show welcome