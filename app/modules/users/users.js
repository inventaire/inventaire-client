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
        'u(sers)/:id/contributions(/)': 'showUserContributionsFromRoute',
        // Aliases
        'u(sers)(/)': 'showSearchUsers'
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
      'show:user:contributions': showUserContributions
    })

    app.reqres.setHandlers({
      // Refreshing relations can be useful
      // to refresh notifications counters that depend on app.relations
      'refresh:relations': initRelations
    })
  }
}

const API = {
  showUserInventory (id) {
    app.execute('show:inventory:user', id)
  },
  showUserItemsByEntity (username, uri) {
    app.execute('show:user:items:by:entity', username, uri)
  },
  showUserListings (id) {
    app.execute('show:user:listings', id)
  },
  showUserContributionsFromRoute (idOrUsername) {
    const filter = app.request('querystring:get', 'filter')
    showUserContributions(idOrUsername, filter)
  },
  showUser (id) { app.execute('show:inventory:user', id) },
  showSearchUsers () { app.execute('show:users:search') }
}

async function showUserContributions (idOrUsernameOrModel, filter) {
  try {
    const user = await app.request('resolve:to:userModel', idOrUsernameOrModel)
    if (app.request('require:loggedIn', user.get('contributionsPathname'))) {
      const username = user.get('username')
      let path = `users/${username}/contributions`
      if (filter) path += `?filter=${filter}`
      const title = i18n('contributions_by', { username })
      app.navigate(path, { metadata: { title } })
      if (app.request('require:admin:access')) {
        const { default: Contributions } = await import('./views/contributions.js')
        app.layout.showChildView('main', new Contributions({ user, filter }))
      }
    }
  } catch (err) {
    app.execute('show:error', err)
  }
}
