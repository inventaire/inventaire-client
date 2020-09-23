import Groups from './collections/groups'
import GroupBoard from './views/group_board'
import initGroupHelpers from './lib/group_helpers'
import fetchData from 'lib/data/fetch'
import InviteByEmail from './views/invite_by_email'
import CreateGroupLayout from './views/create_group_layout'

export default {
  define (Redirect, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'groups/:id/settings(/)': 'showGroupBoard',

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

    return app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
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

var initRequestsCollectionsEvent = function () {
  if (app.user.loggedIn) {
    return app.request('waitForNetwork')
    .then(() => app.vent.trigger('network:requests:update'))
  }
}

var API = {
  redirectToInventoryNetwork () { return app.execute('show:inventory:network') },
  redirectToInventoryPublic () { return app.execute('show:inventory:public') },

  // Named showGroupBoard and not showGroupSettings
  // as GroupSettings are a child view of GroupBoard
  showGroupBoard (slug) {
    if (app.request('require:loggedIn', `groups/${slug}/settings`)) {
      return app.request('get:group:model', slug)
      .then(showGroupBoardFromModel)
      .catch(err => {
        _.error(err, 'get:group:model err')
        return app.execute('show:error:missing')
      })
    }
  },

  showInviteFriendByEmail () { return app.layout.modal.show(new InviteByEmail()) },
  showCreateGroupLayout () { return app.layout.modal.show(new CreateGroupLayout()) }
}

var showGroupBoardFromModel = function (model, options = {}) {
  if (model.mainUserIsMember()) {
    return model.beforeShow()
    .then(() => {
      const { openedSection } = options
      app.layout.main.show(new GroupBoard({ model, standalone: true, openedSection }))
      return app.navigateFromModel(model, 'boardPathname')
    })
  } else {
    // If the user isnt a member, redirect to the standalone group inventory
    return app.execute('show:inventory:group', model, true)
  }
}

var getNetworkNotificationsCount = function () {
  // TODO: introduce a 'read' flag on the relation document to stop counting
  // requests that were already seen.
  const friendsRequestsCount = app.relations?.otherRequested.length || 0
  const mainUserInvitationsCount = app.groups?.mainUserInvited.length || 0
  return friendsRequestsCount + mainUserInvitationsCount
}
