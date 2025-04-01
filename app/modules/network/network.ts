import { addRoutes } from '#app/lib/router'
import { commands } from '#app/radio'

export default {
  initialize () {
    addRoutes({
      // Legacy redirections
      '/network/friends(/)': 'redirectToInventoryNetwork',
      '/network(/users)(/)': 'redirectToInventoryNetwork',
      '/network(/users)(/search)(/)': 'redirectToInventoryNetwork',
      '/network/users/friends(/)': 'redirectToInventoryNetwork',
      '/network/users/invite(/)': 'redirectToInventoryNetwork',
      '/network/groups(/)': 'redirectToInventoryNetwork',
      '/network/groups/search(/)': 'redirectToInventoryNetwork',
      '/network/groups/user(/)': 'redirectToInventoryNetwork',
      '/network/groups/settings(/)': 'redirectToInventoryNetwork',
      '/network/users/nearby(/)': 'redirectToInventoryPublic',
      '/network/groups/nearby(/)': 'redirectToInventoryPublic',
    }, controller)
  },
}

const controller = {
  redirectToInventoryNetwork () { commands.execute('show:inventory:network') },
  redirectToInventoryPublic () { commands.execute('show:inventory:public') },
} as const
