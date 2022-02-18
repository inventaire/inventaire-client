import log_ from '#lib/loggers'
import preq from '#lib/preq'
import { i18n } from '#user/lib/i18n'
import initUsersCollections from './users_collections.js'
import initHelpers from './helpers.js'
import initRequests from './requests.js'
import initInvitations from './invitations.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'u(sers)/:id/contributions(/)': 'showUserContributions',
        // Aliases
        'u(sers)/:id(/)': 'showUser',
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
    if (app.request('require:loggedIn', user.get('contributions'))) {
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

  showUser (id) { app.execute('show:inventory:user', id) },
  showSearchUsers () { app.execute('show:users:search') }
}

const initRelations = function () {
  if (app.user.loggedIn) {
    return preq.get(app.API.relations)
    .then(relations => {
      app.relations = relations
      app.execute('waiter:resolve', 'relations')
    })
    .catch(log_.Error('relations init err'))
  } else {
    app.relations = {
      friends: [],
      userRequested: [],
      otherRequested: [],
      network: []
    }
    app.execute('waiter:resolve', 'relations')
  }
}
