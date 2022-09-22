import app from './app.js'
import getConfig from './get_config.js'
import initPiwik from '#lib/piwik'
import API from '#app/api/api'
import initDataWaiters from '#lib/data/waiters'
import Redirect from '#modules/redirect'
import User from '#user/user'
import Users from '#users/users'
import Entities from '#entities/entities'
import Search from '#search/search'
import Add from '#inventory/add'
import Inventory from '#inventory/inventory'
import Transactions from '#transactions/transactions'
import Network from '#network/network'
import Groups from '#groups/groups'
import Notifications from '#notifications/notifications'
import Settings from '#settings/settings'
import Tasks from '#tasks/tasks'
import Shelves from '#shelves/shelves'
import Listings from '#listings/listings'
import initMap from '#map/map'
import AppLayout from '#general/views/app_layout'
import reloadOnceADay from '#lib/reload_once_a_day'
import initQuerystringHelpers from '#lib/querystring_helpers'

window.app = app

export default async function () {
  // gets all the routes used in the app
  app.API = API

  const configPromise = getConfig()

  initDataWaiters()

  // Initialize all the modules and their routes before app.start()
  // The first routes initialized have the lowest priority
  // /!\ routes defined before Redirect will be overriden by the glob
  Redirect.initialize()
  // other modules might need to access app.user so it should be initialized early on
  User.initialize()
  // Users and Entities need to be initialize for the Welcome item panel to work
  Users.initialize()
  Entities.initialize()
  Search.initialize()
  Add.initialize()
  Inventory.initialize()
  Transactions.initialize()
  Network.initialize()
  Groups.initialize()
  Notifications.initialize()
  Settings.initialize()
  Tasks.initialize()
  Shelves.initialize()
  Listings.initialize()
  initMap()
  initQuerystringHelpers()

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
