export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
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
      },
    })

    new Router({ controller: API })

    app.reqres.setHandlers({ 'get:network:invitations:count': getNetworkNotificationsCount })
  },
}

const API = {
  redirectToInventoryNetwork () { app.execute('show:inventory:network') },
  redirectToInventoryPublic () { app.execute('show:inventory:public') },
}

const getNetworkNotificationsCount = function () {
  // TODO: introduce a 'read' flag on the relation document to stop counting
  // requests that were already seen.
  const friendsRequestsCount = app.relations?.otherRequested.length || 0
  const mainUserInvitationsCount = app.groups?.mainUserInvited.length || 0
  return friendsRequestsCount + mainUserInvitationsCount
}
