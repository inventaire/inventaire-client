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
        'u(sers)(/)': 'showHome',
        'u(sers)/network(/)': 'showNetworkHome',
        'u(sers)/public(/)': 'showPublicHome',
        'u(sers)/:id(/)': 'showUserProfile',
        'u(sers)/:id/inventory/:uri(/)': 'showUserItemsByEntity',
        'u(sers)/:id/inventory(/)': 'showUserInventory',
        'u(sers)/:id/lists(/)': 'showUserListings',
        'u(sers)/:id/contributions(/)': 'showUserContributionsFromRoute',
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
      'show:main:user:profile': showMainUserProfile,
      'show:user:contributions': showUserContributions
    })

    app.reqres.setHandlers({
      // Refreshing relations can be useful
      // to refresh notifications counters that depend on app.relations
      'refresh:relations': initRelations
    })
  }
}

export async function showHome () {
  if (app.request('require:loggedIn', app.user.get('inventoryPathname'))) {
    // Give focus to the home button so that hitting tab gives focus
    // to the search input
    $('#home').focus()
    return showUsersHome({ users: app.user })
  }
}

export async function showUserProfile (user) {
  return showUsersHome({ user })
}

export async function showMainUserProfile () {
  return showUsersHome({ user: app.user })
}

export async function showUserInventory (user) {
  return showUsersHome({ user, profileSection: 'inventory' })
}

export async function showUserListings (user) {
  return showUsersHome({ user, profileSection: 'listings' })
}

const API = {
  showHome,
  showNetworkHome () {
    return showUsersHome({ section: 'network' })
  },
  showPublicHome () {
    return showUsersHome({ section: 'public' })
  },
  showUserProfile,
  showUserInventory,
  showUserListings,
  showUserItemsByEntity (username, uri) {
    app.execute('show:user:items:by:entity', username, uri)
  },
  showUserContributionsFromRoute (idOrUsername) {
    const filter = app.request('querystring:get', 'filter')
    showUserContributions(idOrUsername, filter)
  },
}

export async function showUsersHome ({ user, group, section, profileSection }) {
  const { default: UsersHomeLayout } = await import('#users/components/users_home_layout.svelte')
  const props = { section, profileSection }
  if (user) props.user = await app.request('resolve:to:user', user)
  if (group) props.group = await app.request('resolve:to:group', group)
  app.layout.showChildComponent('main', UsersHomeLayout, { props })
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
