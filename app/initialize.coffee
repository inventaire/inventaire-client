require('lib/handlebars_helpers').initialize()
app = require 'app'

_.extend _, require 'lib/utils'

#changing the default attribute to fit CouchDB
Backbone.Model.prototype.idAttribute = '_id'

Backbone.Marionette.View.prototype.addMultipleSelectorEvents = ->
  @events ||= new Object
  if @multipleSelectorEvents?
    for selectorsString, handler of @multipleSelectorEvents
      selectors = selectorsString.split ' '
      event = selectors.shift()
      selectors.forEach (selector)=>
        @events["#{event} #{selector}"] = handler

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

  app.Lib.i18n.initialize(app)
  app.module 'user', app.Module.User(app.user, app, Backbone, Marionette, $, _)
  app.request('i18n:set')
  .done ->

    # initialize layout after user to get i18n data
    app.layout = new app.Layout.App
    app.module 'foundation', app.Module.Foundation(app.Foundation, app, Backbone, Marionette, $, _)

    if app.user.loggedIn
      app.module 'contacts', app.Module.Contacts(app.Contacts, app, Backbone, Marionette, $, _)
      app.module 'inventory', app.Module.Inventory(app.Inventory, app, Backbone, Marionette, $, _)
    else
      welcome = new app.View.Welcome
      app.layout.main.show welcome