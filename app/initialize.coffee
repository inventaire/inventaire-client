require('lib/handlebars_helpers').initialize()
app = require 'app'

_.extend _, require 'lib/utils'

#changing the default attribute to fit CouchDB
Backbone.Model.prototype.idAttribute = '_id'

_.extend Marionette.View.prototype, require('lib/views_utils')

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

  app.lib.i18n.initialize(app)

  app.module 'user', require 'modules/user'

  # initialize all the module routes before app.start()
  # the first routes initialized have the lowest priority
  app.module 'redirect', require 'modules/redirect'
  app.module 'entities', require 'modules/entities'
  app.module 'inventory', require 'modules/inventory'

  app.request('i18n:set')
  .done ->

    # initialize layout after user to get i18n data
    app.layout = new app.Layout.App
    app.lib.foundation.initialize(app)
    app.execute 'user:menu:update'

    if app.user.loggedIn
      app.module 'contacts', require 'modules/contacts'
    else
      app.layout.main.show new app.View.Welcome

    _.log 'app:before:start'
    app.start()