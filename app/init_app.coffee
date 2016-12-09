module.exports = ->
  app = require 'app'
  window.app = app

  _ = require('lib/builders/utils')()

  # gets all the routes used in the app
  app.API = require('api/api')(_)

  configPromise = require('./get_config')()

  require('lib/handlebars_helpers/base').initialize(app.API)
  require('lib/global_libs_extender')(_)
  require('lib/global_helpers')(app, _)

  # setting reqres to trigger methods on data:ready events
  require('lib/data/state')()

  # initialize all the modules and their routes before app.start()
  # the first routes initialized have the lowest priority

  # /!\ routes defined before Redirect will be overriden by the glob
  app.module 'Redirect', require 'modules/redirect'
  # other modules might need to access app.user so it should be initialized early on
  app.module 'User', require 'modules/user/user'
  # Users and Entities need to be initialize for the Welcome item panel to work
  app.module 'Users', require 'modules/users/users'
  app.module 'Entities', require 'modules/entities/entities'
  app.module 'Search', require 'modules/search/search'
  app.module 'Inventory', require 'modules/inventory/inventory'
  app.module 'Transactions', require 'modules/transactions/transactions'
  app.module 'Network', require 'modules/network/network'
  app.module 'Notifications', require 'modules/notifications/notifications'
  app.module 'Settings', require 'modules/settings/settings'
  require('modules/map/map')()
  require('modules/comments/comments')()

  AppLayout = require 'modules/general/views/app_layout'

  Promise.all [
    app.request 'wait:for', 'i18n'
    configPromise
  ]
  .then ->
    # Initialize the application on DOM ready event.
    $ ->
      # initialize layout after user to get i18n data
      app.layout = new AppLayout
      require('lib/foundation').initialize(app)
      app.execute 'show:user:menu:update'

      app.start()

      app.execute 'waiter:resolve', 'layout'

  require('lib/piwik')()
  require('lib/jquery-jk').initialize($)
