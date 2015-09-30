module.exports = ->
  app = require 'app'
  window.app = app

  _ = require('lib/builders/utils')(Backbone, window._, app, window)

  _.extend app, require 'structure'

  # gets all the routes used in the app
  app.API = require('api/api')(_)

  require('lib/handlebars_helpers/base').initialize(app.API)
  require('lib/global_libs_extender')(_)
  require('lib/global_helpers')(app, _)

  LocalDB = require('lib/data/local_db')(window, _)
  # constructor for interactions between module and LevelDb/IndexedDb
  app.LocalCache = require('lib/data/local_cache')(LocalDB, _, require 'lib/preq')

  # setting reqres to trigger methods on data:ready events
  app.data = require('lib/data_state')
  app.data.initialize()

  require('lib/i18n').initialize(app)

  # initialize all the modules and their routes before app.start()
  # the first routes initialized have the lowest priority

  # /!\ routes defined before Redirect will be overriden by the glob
  app.module 'Redirect', require 'modules/redirect'
  # Users and Entities need to be initialize for the Welcome item panel to work
  app.module 'Users', require 'modules/users/users'
  app.module 'Entities', require 'modules/entities/entities'
  app.module 'User', require 'modules/user/user'
  app.module 'Search', require 'modules/search/search'
  app.module 'Inventory', require 'modules/inventory/inventory'
  app.module 'Transactions', require 'modules/transactions/transactions'
  app.module 'Network', require 'modules/network/network'
  require('modules/comments/comments')()
  if app.user.loggedIn
    app.module 'Settings', require 'modules/settings/settings'
    app.module 'Notifications', require 'modules/notifications/notifications'


  AppLayout = require 'modules/general/views/app_layout'

  app.request('i18n:set')
  .done ->

    # Initialize the application on DOM ready event.
    $ ->
      # initialize layout after user to get i18n data
      app.layout = new AppLayout
      app.lib.foundation.initialize(app)
      app.execute 'show:user:menu:update'

      app.start()

  require('lib/piwik')()
  require('lib/jquery-jk').initialize($)
