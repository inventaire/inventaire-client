import { isEntityUri, isUsername, isItemId } from '#lib/boolean_tests'
import assert_ from '#lib/assert_types'
import log_ from '#lib/loggers'
import initQueries from './lib/queries.js'
import showItemCreationForm from './lib/show_item_creation_form.js'
import itemActions from './lib/item_actions.js'
import { parseQuery, currentRoute, buildPath } from '#lib/location'
import error_ from '#lib/error'
import { getAuthorsByProperty } from '#inventory/components/lib/item_show_helpers'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'u(sers)(/)': 'showGeneralInventory',
        'inventory(/)': 'showGeneralInventory',
        'u(sers)/network(/)': 'showNetworkInventory',
        'u(sers)/public(/)': 'showPublicInventory',
        // Legacy
        'inventory/network(/)': 'showNetworkInventory',
        'inventory/public(/)': 'showPublicInventory',
        'inventory/nearby(/)': 'showPublicInventory',

        'inventory/:username(/)': 'showUserInventoryFromUrl',
        // 'title' is a legacy parameter
        'inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity',
        'items/:id(/)': 'showItemFromId',
        'items(/)': 'showGeneralInventory',
      }
    })

    new Router({ controller: API })

    initQueries(app)
    initializeInventoriesHandlers(app)
  }
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
    if (_.isString(options)) options = parseQuery(options)
    else options = options || {}
    const { filter } = options
    const url = buildPath('users/public', { filter })

    if (app.request('require:loggedIn', url)) {
      showInventory({ section: 'public', filter })
      app.navigate(url)
    }
  },

  showUserInventory (user, standalone, listings) {
    return showInventory({ user, standalone, listings })
  },

  showUserListings (username) {
    return showInventory({ user: username, standalone: true, listings: true })
  },

  showMainUserListings () { API.showUserListings(app.user.get('username')) },

  showGroupListings (group) {
    return showInventory({ group, standalone: true, listings: true })
  },

  showUserInventoryFromUrl (username) {
    return showInventory({ user: username, standalone: true })
  },

  showGroupInventory (group, standalone = true) {
    return showInventory({ group, standalone })
  },

  showItemFromId (id) {
    const pathname = `/items/${id}`
    if (!isItemId(id)) return app.execute('show:error:missing', { pathname })

    return app.request('get:item:model', id)
    .then(app.Execute('show:item'))
    .catch(err => {
      if (err.statusCode === 404) {
        return app.execute('show:error:missing', { pathname })
      } else {
        app.execute('show:error', err, 'showItemFromId')
      }
    })
  },

  showUserItemsByEntity (username, uri, label) {
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
  }
}

const showItemsFromModels = function (items) {
  // Accept either an items collection or an array of items models
  if (_.isArray(items)) items = new Backbone.Collection(items)

  if (items?.length == null) {
    throw new Error('shouldnt be at least an empty array here?')
  }

  if (items.length === 0) {
    app.execute('show:error:missing')
  } else if (items.length === 1) {
    const item = items.models[0]
    showItemModal(item, { fallbackToUserInventory: true })
  } else {
    showItemsList(items)
  }
}

const showInventory = async options => {
  const { default: UsersHomeLayout } = await import('#users/views/users_home_layout.js')
  app.layout.showChildView('main', new UsersHomeLayout(options))
}

const showItemsList = async collection => {
  const { default: ItemsCascade } = await import('#inventory/components/items_cascade.svelte')
  app.layout.showChildComponent('main', ItemsCascade, {
    props: {
      items: getItemsListFromItemsCollection(collection)
    }
  })
}

export const getItemsListFromItemsCollection = collection => {
  return collection.models.map(model => {
    const item = model.toJSON()
    item.user = model.user.toJSON()
    return item
  })
}

const showItemModal = async (model, options = {}) => {
  assert_.object(model)
  const { fallbackToUserInventory = false } = options

  // Do not scroll top as the modal might be displayed down at the level
  // where the item show event was triggered
  app.navigateFromModel(model, { preventScrollTop: true })
  const newRoute = currentRoute()
  const previousRoute = Backbone.history.last.find(route => route !== newRoute)

  const navigateAfterModal = function () {
    if (currentRoute() !== newRoute) return
    if (fallbackToUserInventory || !previousRoute || previousRoute === newRoute) {
      app.execute('show:inventory:user', model.get('owner'))
    } else {
      app.navigate(previousRoute, { preventScrollTop: true })
    }
  }

  app.execute('modal:open', 'large')
  app.execute('modal:spinner')

  try {
    const [ { default: ItemShow } ] = await Promise.all([
      await import('#inventory/components/item_show.svelte'),
      model.waitForEntity,
      model.grabWorks(),
      model.waitForUser,
    ])
    const authorsByProperty = await getAuthorsByProperty(model.works)
    app.layout.showChildComponent('modal', ItemShow, {
      props: {
        item: model.toJSON(),
        user: model.user.toJSON(),
        entity: model.entity.toJSON(),
        works: model.works.map(work => work.toJSON()),
        authorsByProperty,
        fallback: navigateAfterModal,
      }
    })
  } catch (err) {
    app.execute('show:error', err)
  }
}

const initializeInventoriesHandlers = function (app) {
  app.commands.setHandlers({
    'show:inventory': showInventory,
    'show:inventory:section' (section) {
      switch (section) {
      case 'user': return API.showUserInventory(app.user)
      case 'network': return API.showNetworkInventory()
      case 'public': return API.showPublicInventory()
      default: throw error_.new('unknown section', 400, { section })
      }
    },

    'show:inventory:network': API.showNetworkInventory,
    'show:inventory:public': API.showPublicInventory,

    'show:users:nearby' () { return API.showPublicInventory({ filter: 'users' }) },
    'show:groups:nearby' () { return API.showPublicInventory({ filter: 'groups' }) },

    // user can be either a username or a user model
    'show:inventory:user' (user) {
      API.showUserInventory(user, true)
    },

    'show:inventory:main:user' (listings) {
      API.showUserInventory(app.user, true, listings)
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

    'show:item': showItemModal,
    'show:item:byId': API.showItemFromId,

    'show:user:listings': API.showUserListings,
    'show:main:user:listings': API.showMainUserListings,
    'show:group:listings': API.showGroupListings,
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
        value: entity.get('uri')
      })
      const updatedItem = await app.request('get:item:model', item.get('_id'))
      return app.execute('show:item', updatedItem)
    }
  })
}
