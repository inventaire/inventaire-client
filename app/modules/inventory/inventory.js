import { isEntityUri, isUsername, isItemId } from '#lib/boolean_tests'
import assert_ from '#lib/assert_types'
import log_ from '#lib/loggers'
import initQueries from './lib/queries.js'
import initLayout from './lib/layout.js'
import showItemCreationForm from './lib/show_item_creation_form.js'
import itemActions from './lib/item_actions.js'
import { parseQuery, currentRoute, buildPath } from '#lib/location'
import error_ from '#lib/error'
import { getAuthorsByProperty } from '#inventory/components/lib/item_show_helpers'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'inventory(/)': 'showGeneralInventory',
        'inventory/network(/)': 'showNetworkInventory',
        'inventory/public(/)': 'showPublicInventory',
        'inventory/:username(/)': 'showUserInventoryFromUrl',
        // 'title' is a legacy parameter
        'inventory/:username/:entity(/:title)(/)': 'showUserItemsByEntity',
        'items/:id(/)': 'showItemFromId',
        'items(/)': 'showGeneralInventory',
        // 'name' is a legacy parameter
        'g(roups)/:id(/:name)(/)': 'showGroupInventory'
      }
    })

    new Router({ controller: API })

    initQueries(app)
    initializeInventoriesHandlers(app)
    initLayout(app)
  }
}

const API = {
  showGeneralInventory () {
    if (app.request('require:loggedIn', 'inventory')) {
      API.showUserInventory(app.user)
      // Give focus to the home button so that hitting tab gives focus
      // to the search input
      return $('#home').focus()
    }
  },

  showNetworkInventory () {
    if (app.request('require:loggedIn', 'inventory/network')) {
      showInventory({ section: 'network' })
      app.navigate('inventory/network')
    }
  },

  // Do not use default parameter `(options = {})`
  // as the router might pass `null` as first argument
  showPublicInventory (options) {
    if (_.isString(options)) options = parseQuery(options)
    else options = options || {}
    const { filter } = options
    const url = buildPath('inventory/public', { filter })

    if (app.request('require:loggedIn', url)) {
      showInventory({ section: 'public', filter })
      app.navigate(url)
    }
  },

  showUserInventory (user, standalone) {
    return showInventory({ user, standalone })
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
    const pathname = `/inventory/${username}/${uri}`
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
    const fallback = () => API.showUserInventory(item.get('owner'), true)
    showItemModal(item, fallback)
  } else {
    showItemsList(items)
  }
}

const showInventory = async options => {
  const { default: InventoryLayout } = await import('./views/inventory_layout.js')
  app.layout.showChildView('main', new InventoryLayout(options))
}

const showItemsList = async collection => {
  const { default: ItemsCascade } = await import('./views/items_cascade.js')
  app.layout.showChildView('main', new ItemsCascade({ collection }))
}

const showItemModal = async (model, fallback) => {
  assert_.object(model)

  // Do not scroll top as the modal might be displayed down at the level
  // where the item show event was triggered
  app.navigateFromModel(model, { preventScrollTop: true })
  const newRoute = currentRoute()
  const previousRoute = Backbone.history.last.find(pathname => pathname !== newRoute)

  const navigateAfterModal = function () {
    if (currentRoute() !== newRoute) return
    if (!previousRoute || previousRoute === newRoute) {
      app.execute('show:inventory:user', model.get('owner'))
    } else {
      app.navigate(previousRoute, { preventScrollTop: true })
    }
  }

  if (!fallback) fallback = navigateAfterModal

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
        fallback,
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
      return API.showUserInventory(user, true)
    },

    'show:inventory:main:user' () {
      return API.showUserInventory(app.user, true)
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
