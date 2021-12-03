import log_ from 'lib/loggers'
import Groups from './collections/groups'
import initGroupHelpers from './lib/group_helpers'
import fetchData from 'lib/data/fetch'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'groups/:id/settings(/)': 'showGroupBoard',
        'g(roups)(/)': 'showSearchGroups',

        // Legacy redirections
        'network/friends(/)': 'redirectToInventoryNetwork',
        'network(/users)(/)': 'redirectToInventoryNetwork',
        'network(/users)(/search)(/)': 'redirectToInventoryNetwork',
        'network/users/friends(/)': 'redirectToInventoryNetwork',
        'network/users/invite(/)': 'redirectToInventoryNetwork',
        'network/groups(/)': 'redirectToInventoryNetwork',
        'network/groups/search(/)': 'redirectToInventoryNetwork',
        'network/groups/user(/)': 'redirectToInventoryNetwork',
        'network/groups/settings(/)': 'redirectToInventoryNetwork',
        'network/users/nearby(/)': 'redirectToInventoryPublic',
        'network/groups/nearby(/)': 'redirectToInventoryPublic',
        'network/groups/create(/)': 'showCreateGroupLayout',
        'network/groups/settings/:id(/)': 'showGroupBoard'
      }
    })

    new Router({ controller: API })

    app.commands.setHandlers({
      'show:group:create': API.showCreateGroup,
      'show:group:board': showGroupBoardFromModel,
      'show:invite:friend:by:email': API.showInviteFriendByEmail,
      'create:group': API.showCreateGroupLayout
    })

    app.reqres.setHandlers({ 'get:network:invitations:count': getNetworkNotificationsCount })

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
  redirectToInventoryNetwork () { app.execute('show:inventory:network') },
  redirectToInventoryPublic () { app.execute('show:inventory:public') },

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

  async showInviteFriendByEmail () {
    const { default: InviteByEmail } = await import('./views/invite_by_email')
    app.layout.showChildView('modal', new InviteByEmail())
  },

  async showCreateGroupLayout () {
    const { default: CreateGroupLayout } = await import('./views/create_group_layout')
    app.layout.modal.show(new CreateGroupLayout())
    app.layout.showChildView('modal', new CreateGroupLayout())
  },

  showSearchGroups () {
    app.execute('show:groups:search')
  },
}

const showGroupBoardFromModel = async (model, options = {}) => {
  if (model.mainUserIsMember()) {
    const [ { default: GroupBoard } ] = await Promise.all([
      import('./views/group_board'),
      model.beforeShow()
    ])
    const { openedSection } = options
    app.layout.showChildView('main', new GroupBoard({ model, standalone: true, openedSection }))
    app.navigateFromModel(model, 'boardPathname')
  } else {
    // If the user isnt a member, redirect to the standalone group inventory
    app.execute('show:inventory:group', model, true)
  }
}

const getNetworkNotificationsCount = function () {
  // TODO: introduce a 'read' flag on the relation document to stop counting
  // requests that were already seen.
  const friendsRequestsCount = app.relations?.otherRequested.length || 0
  const mainUserInvitationsCount = app.groups?.mainUserInvited.length || 0
  return friendsRequestsCount + mainUserInvitationsCount
}
