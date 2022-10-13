import { i18n } from '#user/lib/i18n'
import initUsersCollections from './users_collections.js'
import initHelpers from './helpers.js'
import initRequests from './requests.js'
import initInvitations from './invitations.js'
import { initRelations } from '#users/lib/relations'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'u(sers)/:id(/)': 'showUserInventory',
        'u(sers)/:id/inventory/:uri(/)': 'showUserItemsByEntity',
        'u(sers)/:id/inventory(/)': 'showUserInventory',
        'u(sers)/:id/lists(/)': 'showUserListings',
        'u(sers)/:id/contributions(/)': 'showUserContributions',
      }
    })

    new Router({ controller: API })

    app.users = initUsersCollections(app)
    initHelpers(app)
    initRequests(app)
    initInvitations(app)
    initRelations()

    app.commands.setHandlers({
      'show:user': app.Execute('show:inventory:user'),
      'show:user:contributions': API.showUserContributions
    })

    app.reqres.setHandlers({
      // Refreshing relations can be useful
      // to refresh notifications counters that depend on app.relations
      'refresh:relations': initRelations
    })
  }
}

const API = {
  async showUserContributions (idOrUsernameOrModel) {
    const user = await app.request('resolve:to:userModel', idOrUsernameOrModel)
    if (app.request('require:loggedIn', user.get('contributionsPathname'))) {
      const username = user.get('username')
      const path = `users/${username}/contributions`
      const title = i18n('contributions_by', { username })
      app.navigate(path, { metadata: { title } })
      if (app.request('require:admin:access')) {
        const { default: Contributions } = await import('./views/contributions.js')
        app.layout.showChildView('main', new Contributions({ user }))
      }
    }
  },

  showUserInventory (id) {
    app.execute('show:inventory:user', id)
  },
  showUserItemsByEntity (username, uri) {
    app.execute('show:user:items:by:entity', username, uri)
  },
  showUserListings (id) {
    app.execute('show:user:listings', id)
  },
}
