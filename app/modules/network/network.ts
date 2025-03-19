import app from '#app/app'
import { getGroupInvitations } from '../groups/lib/groups_data'

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

    new Router({ controller })
  },
}

const controller = {
  redirectToInventoryNetwork () { app.execute('show:inventory:network') },
  redirectToInventoryPublic () { app.execute('show:inventory:public') },
}

// TODO: introduce a 'read' flag on the relation document to stop counting
// requests that were already seen.
export async function getNetworkNotificationsCount () {
  const [ groupsInvidations ] = await Promise.all([
    getGroupInvitations(),
    app.request('wait:for', 'relations'),
  ])
  const friendshipRequestsCount = app.relations?.otherRequested.length || 0
  const mainUserInvitationsCount = groupsInvidations.length || 0
  return friendshipRequestsCount + mainUserInvitationsCount
}
