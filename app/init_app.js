import app from './app'
import getConfig from './get_config'

window.location.root = window.location.protocol + '//' + window.location.host

export default function () {
  window.app = app

  // const _ = require('lib/builders/utils')()

  // gets all the routes used in the app
  app.API = require('api/api')

  const configPromise = getConfig()

  require('lib/handlebars_helpers/init')
  require('lib/global_libs_extender')
  require('lib/global_helpers')
  require('lib/data/waiters').default()

  // initialize all the modules and their routes before app.start()
  // the first routes initialized have the lowest priority

  // /!\ routes defined before Redirect will be overriden by the glob
  app.module('Redirect', require('modules/redirect'))
  // other modules might need to access app.user so it should be initialized early on
  // app.module('User', require('modules/user/user'))
  // // Users and Entities need to be initialize for the Welcome item panel to work
  // app.module('Users', require('modules/users/users'))
  // app.module('Entities', require('modules/entities/entities'))
  // app.module('Search', require('modules/search/search'))
  // app.module('Add', require('modules/inventory/add'))
  // app.module('Inventory', require('modules/inventory/inventory'))
  // app.module('Transactions', require('modules/transactions/transactions'))
  // app.module('Network', require('modules/network/network'))
  // app.module('Notifications', require('modules/notifications/notifications'))
  // app.module('Settings', require('modules/settings/settings'))
  // app.module('Tasks', require('modules/tasks/tasks'))
  // app.module('Shelves', require('modules/shelves/shelves'))
  // require('modules/map/map')()

  const AppLayout = require('modules/general/views/app_layout')

  Promise.all([
    app.request('wait:for', 'i18n'),
    configPromise
  ])
  .then(() => {
    // Initialize the application on DOM ready event.
    $(() => {
    // initialize layout after user to get i18n data
      app.layout = new AppLayout()

      app.start()

      app.execute('waiter:resolve', 'layout')

      require('lib/reload_once_a_day')()
    })
  })

  configPromise.then(() => require('lib/piwik')())
}
