import { isString } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { assertString } from '#app/lib/assert_types'
import { isEntityUri, isUsername, isItemId } from '#app/lib/boolean_tests'
import { parseQuery, buildPath } from '#app/lib/location'
import preq from '#app/lib/preq'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import type { EntityUri } from '#server/types/entity'
import type { UserId, Username } from '#server/types/user'
import { showUsersHome } from '#users/users'
import { resolveToUser } from '../users/users_data.ts'
import { getItemsByUserIdAndEntities, getNearbyItems, getNetworkItems } from './lib/queries.ts'
import type { SerializedItemWithUserData } from './lib/items.ts'

export default {
  initialize () {
    addRoutes({
      // Legacy
      '/inventory(/)': 'showGeneralInventory',
      '/inventory/network(/)': 'showNetworkInventory',
      '/inventory/public(/)': 'showPublicInventory',
      '/inventory/nearby(/)': 'showPublicInventory',
      '/inventory/:username(/)': 'showUserInventoryFromUrl',
      '/inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity',

      '/items/:id(/)': 'showItemFromId',
      '/items(/)': 'showGeneralInventory',
    }, controller)

    initializeInventoriesHandlers(app)
  },
}

async function showInventory (params) {
  params.profileSection = 'inventory'
  return showUsersHome(params)
}

const controller = {
  showGeneralInventory () {
    if (reqres.request('require:loggedIn', 'items')) {
      controller.showUserInventory(app.user._id)
      // Give focus to the home button so that hitting tab gives focus
      // to the search input
      ;(document.querySelector('#home') as HTMLElement).focus()
    }
  },

  showNetworkInventory () {
    if (reqres.request('require:loggedIn', 'users/network')) {
      showInventory({ section: 'network' })
      app.navigate('users/network')
    }
  },

  // Do not use default parameter `(options = {})`
  // as the router might pass `null` as first argument
  showPublicInventory (options) {
    if (isString(options)) options = parseQuery(options)
    else options = options || {}
    const { filter } = options
    const url = buildPath('/users/public', { filter })

    if (reqres.request('require:loggedIn', url)) {
      showInventory({ section: 'public', filter })
      app.navigate(url)
    }
  },

  showUserInventory (user, standalone?) {
    return showInventory({ user, standalone })
  },

  showUserInventoryFromUrl (username) {
    return showInventory({ user: username })
  },

  async showItemFromId (id) {
    showItem({ itemId: id, regionName: 'main' })
  },

  async showUserItemsByEntity (username, uri, label?) {
    try {
      const user = await resolveToUser(username)
      username = user.username
      const pathname = `/users/${username}/inventory/${uri}`
      if (!isUsername(username) || !isEntityUri(uri)) {
        return commands.execute('show:error:missing', { pathname })
      }

      const title = label ? `${label} - ${username}` : `${uri} - ${username}`

      commands.execute('show:loader')
      app.navigate(pathname, { metadata: { title } })

      const items = await getItemsByUserIdAndEntities(user._id, uri)
      await showItems(items)
    } catch (err) {
      commands.execute('show:error', err)
    }
  },
} as const

async function showItems (items: SerializedItemWithUserData[]) {
  if (items.length === 0) {
    commands.execute('show:error:missing')
  } else if (items.length === 1) {
    const item = items[0]
    await showItem({ itemId: item._id })
  } else {
    await showItemsList(items)
  }
}

async function showItemsList (items: SerializedItemWithUserData[]) {
  const { default: ItemsCascade } = await import('#inventory/components/items_cascade.svelte')
  appLayout.showChildComponent('main', ItemsCascade, {
    props: {
      items,
    },
  })
}

interface ShowItem {
  itemId: string
  regionName?: string
  pathnameAfterClosingModal?: string
}

async function showItem ({ itemId, regionName = 'main', pathnameAfterClosingModal }: ShowItem) {
  try {
    assertString(itemId)
    const pathname = `/items/${itemId}`
    if (!isItemId(itemId)) return commands.execute('show:error:missing', { pathname })
    const { items, users } = await preq.get(API.items.byIds({ ids: itemId, includeUsers: true }))
    const item = items[0]
    const user = users[0]
    const { default: ItemShowStandalone } = await import('#inventory/components/item_show_standalone.svelte')
    if (item) {
      appLayout.showChildComponent(regionName, ItemShowStandalone, {
        props: {
          item,
          user,
          pathnameAfterClosingModal,
          autodestroyComponent: () => appLayout.removeCurrentComponent(regionName),
        },
      })
    } else {
      commands.execute('show:error:missing', { pathname })
    }
  } catch (err) {
    commands.execute('show:error', err, 'showItemFromId')
  }
}

const initializeInventoriesHandlers = function (app) {
  commands.setHandlers({
    'show:inventory:network': controller.showNetworkInventory,
    'show:inventory:public': controller.showPublicInventory,

    'show:users:nearby' () { return controller.showPublicInventory({ filter: 'users' }) },
    'show:groups:nearby' () { return controller.showPublicInventory({ filter: 'groups' }) },

    'show:inventory:user' (userId: UserId) {
      controller.showUserInventory(userId, true)
    },

    'show:inventory:main:user' () {
      controller.showUserInventory(app.user, true)
    },

    'show:user:items:by:entity' (username: Username, uri: EntityUri) {
      controller.showUserItemsByEntity(username, uri)
    },
  })

  reqres.setHandlers({
    // Used by #users/components/public_users_nav.svelte
    'items:getNearbyItems': getNearbyItems,
    // Used by #users/components/network_users_nav.svelte
    'items:getNetworkItems': getNetworkItems,
  })
}
