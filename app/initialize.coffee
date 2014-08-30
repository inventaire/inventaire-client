require('lib/handlebars_helpers').initialize()
app = require 'app'

_.extend _, require 'lib/utils'
window.wd = require 'lib/wikidata'

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

  # initialize all the module routes before app.start()
  # the first routes initialized have the lowest priority
  app.module 'notLoggedRoutes', require 'modules/notLoggedRoutes'
  app.module 'User', require 'modules/user'

  if app.user.loggedIn
    app.module 'Redirect', require 'modules/redirect'
    app.module 'Profile', require 'modules/profile'
    app.module 'Entities', require 'modules/entities'
    app.module 'Listings', require 'modules/listings'
    app.module 'Inventory', require 'modules/inventory'
    app.module 'Contacts', require 'modules/contacts'

  app.request('i18n:set')
  .done ->

    # initialize layout after user to get i18n data
    app.layout = new app.Layout.App
    app.lib.foundation.initialize(app)
    app.execute 'show:user:menu:update'

    app.start()

  require('lib/jquery-jk').initialize($)