import { isString, isArray } from 'underscore'
import app from '#app/app'
import assert_ from '#app/lib/assert_types'
import { isEntityUri, isUsername, isItemId } from '#app/lib/boolean_tests'
import { removeCurrentComponent } from '#app/lib/global_libs_extender'
import { parseQuery, buildPath } from '#app/lib/location'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { showUsersHome } from '#users/users'
import itemActions from './lib/item_actions.ts'
import initQueries from './lib/queries.ts'
import showItemCreationForm from './lib/show_item_creation_form.ts'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        // Legacy
        'inventory(/)': 'showGeneralInventory',
        'inventory/network(/)': 'showNetworkInventory',
        'inventory/public(/)': 'showPublicInventory',
        'inventory/nearby(/)': 'showPublicInventory',
        'inventory/:username(/)': 'showUserInventoryFromUrl',
        'inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity',

        'items/:id(/)': 'showItemFromId',
        'items(/)': 'showGeneralInventory',
      },
    })

    new Router({ controller: API })

    initQueries(app)
    initializeInventoriesHandlers(app)
  },
}

async function showInventory (params) {
  params.profileSection = 'inventory'
  return showUsersHome(params)
}

const API = {
  showGeneralInventory () {
    if (app.request('require:loggedIn', app.user.get('inventoryPathname'))) {
      API.showUserInventory(app.user)
      // Give focus to the home button so that hitting tab gives focus
      // to the search input
      return $('#home').focus()
    }
  },

  showNetworkInventory () {
    if (app.request('require:loggedIn', 'users/network')) {
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

    if (app.request('require:loggedIn', url)) {
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

  showGroupInventory (group, standalone = true) {
    return showInventory({ group, standalone })
  },

  async showItemFromId (id) {
    showItem({ itemId: id, regionName: 'main' })
  },

  showUserItemsByEntity (username, uri, label?) {
    const pathname = `/users/${username}/inventory/${uri}`
    if (!isUsername(username) || !isEntityUri(uri)) {
      return app.execute('show:error:missing', { pathname })
    }

    const title = label ? `${label} - ${username}` : `${uri} - ${username}`

    app.execute('show:loader')
    app.navigate(pathname, { metadata: { title } })

    return app.request('get:userId:from:username', username)
    .then(userId => app.request('items:getByUserIdAndEntities', userId, uri))
    .then(showItemsFromModels)
    .catch(log_.Error('showItemShowFromUserAndEntity'))
  },
}

const showItemsFromModels = function (items) {
  // Accept either an items collection or an array of items models
  if (isArray(items)) items = new Backbone.Collection(items)

  if (items?.length == null) {
    throw new Error('shouldnt be at least an empty array here?')
  }

  if (items.length === 0) {
    app.execute('show:error:missing')
  } else if (items.length === 1) {
    const item = items.models[0]
    showItem({ itemId: item._id })
  } else {
    showItemsList(items)
  }
}

const showItemsList = async collection => {
  const { default: ItemsCascade } = await import('#inventory/components/items_cascade.svelte')
  app.layout.showChildComponent('main', ItemsCascade, {
    props: {
      items: getItemsListFromItemsCollection(collection),
    },
  })
}

export const getItemsListFromItemsCollection = collection => {
  return collection.models.map(model => {
    const item = model.toJSON()
    item.user = model.user.toJSON()
    return item
  })
}

interface ShowItem {
  itemId: string
  regionName?: string
  pathnameAfterClosingModal?: string
}

const showItem = async ({ itemId, regionName = 'main', pathnameAfterClosingModal }: ShowItem) => {
  try {
    assert_.string(itemId)
    const pathname = `/items/${itemId}`
    if (!isItemId(itemId)) return app.execute('show:error:missing', { pathname })
    const { items, users } = await preq.get(app.API.items.byIds({ ids: itemId, includeUsers: true }))
    const item = items[0]
    const user = users[0]
    const { default: ItemShowStandalone } = await import('#inventory/components/item_show_standalone.svelte')
    if (item) {
      app.layout.showChildComponent(regionName, ItemShowStandalone, {
        props: {
          item,
          user,
          pathnameAfterClosingModal,
          autodestroyComponent: () => removeCurrentComponent(app.layout.getRegion(regionName)),
        },
      })
    } else {
      app.execute('show:error:missing', { pathname })
    }
  } catch (err) {
    app.execute('show:error', err, 'showItemFromId')
  }
}

const initializeInventoriesHandlers = function (app) {
  app.commands.setHandlers({
    'show:inventory': showInventory,
    'show:inventory:network': API.showNetworkInventory,
    'show:inventory:public': API.showPublicInventory,

    'show:users:nearby' () { return API.showPublicInventory({ filter: 'users' }) },
    'show:groups:nearby' () { return API.showPublicInventory({ filter: 'groups' }) },

    // user can be either a username or a user model
    'show:inventory:user' (user) {
      API.showUserInventory(user, true)
    },

    'show:inventory:main:user' () {
      API.showUserInventory(app.user, true)
    },

    'show:user:items:by:entity' (username, uri) {
      API.showUserItemsByEntity(username, uri)
    },

    'show:inventory:group': API.showGroupInventory,

    'show:inventory:group:byId' (params) {
      const { groupId, standalone } = params
      return app.request('get:group:model', groupId)
      .then(group => API.showGroupInventory(group, standalone))
      .catch(app.Execute('show:error'))
    },

    'show:item:creation:form': showItemCreationForm,

    'show:item': showItem,
    'show:item:byId': API.showItemFromId,
  })

  app.reqres.setHandlers({
    'items:update': itemActions.update,
    'items:delete': itemActions.delete,
    'item:create': itemActions.create,
    'item:main:user:entity:items': async entityUri => {
      const { models } = await app.request('items:getByUserIdAndEntities', app.user.id, entityUri)
      return models
    },
    'item:update:entity': async (item, entity) => {
      await itemActions.update({
        item,
        attribute: 'entity',
        value: entity.get('uri'),
      })
      app.execute('show:item:byId', item.get('_id'))
    },
  })
}
