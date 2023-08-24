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
        'u(sers)(/)': 'showNetworkHome',
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
    app.navigate('users/network')
    return showUsersHome({ section: 'network' })
  },
  showPublicHome () {
    app.navigate('users/public')
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
  try {
    const { default: UsersHomeLayout } = await import('#users/components/users_home_layout.svelte')
    const props = { section, profileSection }
    if (user) props.user = await app.request('resolve:to:user', user)
    if (group) props.group = await app.request('resolve:to:group', group)
    app.layout.showChildComponent('main', UsersHomeLayout, { props })
  } catch (err) {
    app.execute('show:error', err)
  }
}

async function showUserContributions (idOrUsernameOrModel, filter) {
  try {
    const user = await app.request('resolve:to:user', idOrUsernameOrModel)
    const { username } = user
    let path = `users/${username.toLowerCase()}/contributions`
    if (filter) path += `?filter=${filter}`
    const title = i18n('contributions_by', { username })
    app.navigate(path, { metadata: { title } })
    const { default: Contributions } = await import('#entities/components/patches/contributions.svelte')
    app.layout.showChildComponent('main', Contributions, { props: { user, filter } })
  } catch (err) {
    app.execute('show:error', err)
  }
}
