import app from './app'
import getConfig from './get_config'
import initPiwik from 'lib/piwik'
import API from 'api/api'
import initDataWaiters from 'lib/data/waiters'
import Redirect from 'modules/redirect'
import User from 'modules/user/user'
import Users from 'modules/users/users'
import Entities from 'modules/entities/entities'
import Search from 'modules/search/search'
import Add from 'modules/inventory/add'
import Inventory from 'modules/inventory/inventory'
import Transactions from 'modules/transactions/transactions'
import Network from 'modules/network/network'
import Notifications from 'modules/notifications/notifications'
import Settings from 'modules/settings/settings'
import Tasks from 'modules/tasks/tasks'
import Shelves from 'modules/shelves/shelves'
import initMap from 'modules/map/map'
import AppLayout from 'modules/general/views/app_layout'
import reloadOnceADay from 'lib/reload_once_a_day'

window.app = app
window.location.root = window.location.protocol + '//' + window.location.host

export default async function () {
  // gets all the routes used in the app
  app.API = API

  const configPromise = getConfig()

  initDataWaiters()

  // Initialize all the modules and their routes before app.start()
  // The first routes initialized have the lowest priority

  // /!\ routes defined before Redirect will be overriden by the glob
  app.module('Redirect', Redirect)
  // other modules might need to access app.user so it should be initialized early on
  app.module('User', User)
  // Users and Entities need to be initialize for the Welcome item panel to work
  app.module('Users', Users)
  app.module('Entities', Entities)
  app.module('Search', Search)
  app.module('Add', Add)
  app.module('Inventory', Inventory)
  app.module('Transactions', Transactions)
  app.module('Network', Network)
  app.module('Notifications', Notifications)
  app.module('Settings', Settings)
  app.module('Tasks', Tasks)
  app.module('Shelves', Shelves)
  initMap()

  await Promise.all([
    app.request('wait:for', 'i18n'),
    configPromise
  ])

  // Initialize the application on DOM ready event.
  $(() => {
    app.layout = new AppLayout()
    app.start()
    app.execute('waiter:resolve', 'layout')
    reloadOnceADay()
  })

  configPromise.then(initPiwik)
}
