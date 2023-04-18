import log_ from '#lib/loggers'
import Group from './models/group.js'
import Groups from './collections/groups.js'
import initGroupHelpers from './lib/group_helpers.js'
import fetchData from '#lib/data/fetch'
import { showUsersHome } from '#users/users'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'g(roups)/:id(/)': 'showGroupProfile',
        'g(roups)/:id/inventory(/)': 'showGroupInventory',
        'g(roups)/:id/lists(/)': 'showGroupListings',
        'g(roups)/:id/settings(/)': 'showGroupBoard',
        'g(roups)(/)': 'showSearchGroups',

        // Legacy redirections
        'network/groups/create(/)': 'showCreateGroupLayout',
        'network/groups/settings/:id(/)': 'showGroupBoard',
      }
    })

    new Router({ controller: API })

    app.commands.setHandlers({
      'show:group:board': showGroupBoardFromModel,
      'create:group': API.showCreateGroupLayout
    })

    fetchData({
      name: 'groups',
      Collection: Groups,
      condition: app.user.loggedIn
    })

    return app.request('wait:for', 'user')
    .then(initGroupHelpers)
    .then(initRequestsCollectionsEvent.bind(this))
  }
}

const initRequestsCollectionsEvent = function () {
  if (app.user.loggedIn) {
    return app.request('waitForNetwork')
    .then(() => app.vent.trigger('network:requests:update'))
  }
}

const API = {
  showGroupProfile (slug) {
    return showUsersHome({ group: slug })
  },
  showGroupInventory (slug) {
    return showUsersHome({ group: slug, profileSection: 'inventory' })
  },
  showGroupListings (slug) {
    return showUsersHome({ group: slug, profileSection: 'listings' })
  },
  // Named showGroupBoard and not showGroupSettings
  // as GroupSettings are a child view of GroupBoard
  showGroupBoard (slug) {
    const pathname = `groups/${slug}/settings`
    if (app.request('require:loggedIn', pathname)) {
      return app.request('get:group:model', slug)
      .then(showGroupBoardFromModel)
      .catch(err => {
        log_.error(err, 'get:group:model err')
        app.execute('show:error:missing', { pathname })
      })
    }
  },

  async showCreateGroupLayout () {
    const { default: CreateGroupLayout } = await import('./views/create_group_layout.js')
    app.layout.showChildView('modal', new CreateGroupLayout())
  },

  showSearchGroups () {
    app.execute('show:groups:search')
  },
}

const showGroupBoardFromModel = async (group, options = {}) => {
  const model = group instanceof Backbone.Model ? group : new Group(group)
  if (model.mainUserIsMember()) {
    const [ { default: GroupBoard } ] = await Promise.all([
      import('./views/group_board.js'),
      model.beforeShow()
    ])
    const { openedSection } = options
    app.layout.showChildView('main', new GroupBoard({ model, standalone: true, openedSection }))
    app.navigateFromModel(model, 'settingsPathname')
  } else {
    // If the user isnt a member, redirect to the standalone group inventory
    app.execute('show:inventory:group', model, true)
  }
}
