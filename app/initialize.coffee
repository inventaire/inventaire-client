require('lib/uncatched_error_logger').initialize()
require('lib/handlebars_helpers').initialize()

window.sharedLib = sharedLib = require('lib/shared/shared_libs')

app = require 'app'
window.app = app

_.extend _, require('lib/utils'), sharedLib('utils')
_.isMobile = require 'lib/mobile_check'

window.wd = require 'lib/wikidata'
window.location.root = window.location.protocol + '//' + window.location.host

require('lib/vendor_libs_extender').initialize()

# Initialize the application on DOM ready event.
$ ->

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
    app.module 'Search', require 'modules/search/search'
    app.module 'Inventory', require 'modules/inventory'
    app.module 'Profile', require 'modules/profile'
    app.module 'Entities', require 'modules/entities'
    app.module 'Listings', require 'modules/listings'
    app.module 'Contacts', require 'modules/contacts'

  app.request('i18n:set')
  .done ->

    # initialize layout after user to get i18n data
    app.layout = new app.Layout.App
    app.lib.foundation.initialize(app)
    app.execute 'show:user:menu:update'

    app.start()

  require('lib/jquery-jk').initialize($)
  _.ping()
