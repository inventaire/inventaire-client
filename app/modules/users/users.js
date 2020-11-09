import log_ from 'lib/loggers'
import preq from 'lib/preq'
import initUsersCollections from './users_collections'
import initHelpers from './helpers'
import initRequests from './requests'
import initInvitations from './invitations'

export default {
  define () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'u(sers)/:id/contributions(/)': 'showUserContributions',
        // Aliases
        'u(sers)/:id(/)': 'showUser',
        'u(sers)(/)': 'showSearchUsers'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
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
  async showUserContributions (idOrUsername) {
    if (app.request('require:loggedIn', `users/${idOrUsername}/contributions`)) {
      const user = await app.request('resolve:to:userModel', idOrUsername)
      const username = user.get('username')
      const path = `users/${username}/contributions`
      app.navigate(path, { metadata: { title: 'contributions' } })
      if (app.request('require:admin:access')) {
        const { default: UserContributions } = await import('./views/user_contributions')
        return app.layout.main.show(new UserContributions({ user }))
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
