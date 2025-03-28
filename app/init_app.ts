import app from '#app/app'
import initDataWaiters from '#app/lib/data/waiters'
import initQuerystringHelpers from '#app/lib/querystring_helpers'
import reloadOnceADay from '#app/lib/reload_once_a_day'
import Entities from '#entities/entities'
import AppLayout from '#general/components/app_layout.svelte'
import { initQuerystringActions } from '#general/lib/querystring_actions'
import Groups from '#groups/groups'
import Add from '#inventory/add'
import Inventory from '#inventory/inventory'
import Listings from '#listings/listings'
import Redirect from '#modules/redirect'
import Network from '#network/network'
import Notifications from '#notifications/notifications'
import Search from '#search/search'
import Settings from '#settings/settings'
import Shelves from '#shelves/shelves'
import Tasks from '#tasks/tasks'
import Transactions from '#transactions/transactions'
import User from '#user/user'
import Users from '#users/users'
import type { SvelteComponent, ComponentProps, ComponentType } from 'svelte'

export default async function () {
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
  initQuerystringHelpers()
  // Should be run before app start to access the unmodifed url
  initQuerystringActions()

  await app.request('wait:for', 'i18n')
  initAppLayout()
  app.start()
  app.execute('waiter:resolve', 'layout')
  reloadOnceADay()
}

function initAppLayout () {
  const target = document.getElementById('app')
  // Remove spinner
  target.innerHTML = ''
  app.layout = new AppLayout({ target })
  app.layout.showChildComponent = showChildComponent
  app.layout.removeCurrentComponent = removeCurrentComponent
}

export interface RegionComponent {
  component: ComponentType
  props?: ComponentProps<SvelteComponent>
}

type RegionName = 'main' | 'modal' | 'svelteModal'

function showChildComponent (regionName: RegionName, component: ComponentType, options: { props?: ComponentProps<SvelteComponent> } = {}) {
  const props = 'props' in options ? options.props : {}
  if (component != null) {
    app.layout.$set({ [regionName]: { component, props } })
  } else {
    app.layout.$set({ [regionName]: null })
  }
}

function removeCurrentComponent (regionName: RegionName) {
  app.layout.$set({ [regionName]: null })
}
