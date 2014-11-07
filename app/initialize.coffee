require('lib/uncatched_error_logger').initialize()
require('lib/handlebars_helpers').initialize()


window.sharedLib = sharedLib = require('lib/shared/shared_libs')

app = require 'app'
window.app = app

local = require('lib/utils')(Backbone, _, app, window)
shared = sharedLib('utils')(_)
_.extend _, local, shared

# http requests handler returning promises
_.preq = require 'lib/preq'

_.isMobile = require 'lib/mobile_check'

window.wd = require 'lib/wikidata'
window.location.root = window.location.protocol + '//' + window.location.host

require('lib/global_libs_extender').initialize()

# gets all the routes used in the app
app.API = require 'api'

# makes all the require's accessible from app
# might be dramatically heavy from start though
# -> should be refactored to make them functions called at run-time?
_.extend app, require 'structure'

# packaging LevelDb libraries into Level
require('lib/local_dbs').initialize()

# constructor for interactions between module and LevelDb/IndexedDb
app.LocalCache = require('lib/local_cache')

# setting reqres to trigger methods on data:ready events
app.data = require('lib/data_state')
app.data.initialize()

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

  # Initialize the application on DOM ready event.
  $ ->
    # initialize layout after user to get i18n data
    app.layout = new app.Layout.App
    app.lib.foundation.initialize(app)
    app.execute 'show:user:menu:update'

    app.start()

require('lib/jquery-jk').initialize($)
require('lib/svg_inliner').initialize($)
_.ping()