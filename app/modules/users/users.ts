import { isString } from 'underscore'
import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { isUserAcct, isUserId } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import { getQuerystringParameter } from '#app/lib/querystring_helpers'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import type { SerializedLoggedInMainUser } from '#modules/user/lib/main_user'
import type { Group, GroupId, GroupSlug } from '#server/types/group'
import type { UserAccountUri } from '#server/types/server'
import type { UserId, User, Username } from '#server/types/user'
import { i18n } from '#user/lib/i18n'
import { mainUser } from '#user/lib/main_user'
import { resolveToGroup } from '../groups/lib/groups.ts'
import { initRelations } from './lib/relations.ts'
import { getLocalUserAccount, type SerializedUser } from './lib/users.ts'
import { getUserByAcct, getUserByUsername, resolveToUser } from './users_data.ts'

export default {
  initialize () {
    addRoutes({
      '/u(sers)(/)': 'showNetworkHome',
      '/u(sers)/network(/)': 'showNetworkHome',
      '/u(sers)/public(/)': 'showPublicHome',
      '/u(sers)/latest(/)': 'showLatestUsers',
      '/u(sers)/:id(/)': 'showUserProfile',
      '/u(sers)/:id/followers(/)': 'showUserFollowers',
      '/u(sers)/:id/inventory/:uri(/)': 'showUserItemsByEntity',
      '/u(sers)/:id/inventory(/)': 'showUserInventory',
      '/u(sers)/:id/lists(/)': 'showUserListings',
      '/u(sers)/:id/contributions(/)': 'showUserContributionsFromRoute',
    }, controller)

    initRelations()

    commands.setHandlers({
      'show:user': commands.Execute('show:inventory:user'),
      'show:user:contributions': showUserContributions,
    })
  },
}

export async function showHome () {
  if (reqres.request('require:loggedIn', '/')) {
    // Give focus to the home button so that hitting tab gives focus
    // to the search input
    ;(document.querySelector('#home') as HTMLElement).focus()
    return showMainUserProfile()
  }
}

export async function showUserProfile (user) {
  return showUsersHome({ user })
}

export async function showMainUserProfile () {
  await reqres.request('wait:for', 'user')
  return showUsersHome({ user: mainUser as SerializedLoggedInMainUser })
}

export async function showUserInventory (user) {
  return showUsersHome({ user, profileSection: 'inventory' })
}

export async function showUserListings (user) {
  return showUsersHome({ user, profileSection: 'listings' })
}

async function showLatestUsers () {
  if (!reqres.request('require:admin:access')) return
  const { default: LatestUsers } = await import('#users/components/latest_users.svelte')
  appLayout.showChildComponent('main', LatestUsers)
  app.navigate('users/latest', { metadata: { title: i18n('Latest users') } })
}

const controller = {
  showHome,
  showNetworkHome () {
    const pathname = 'users/network'
    app.navigate('users/network')
    if (reqres.request('require:loggedIn', pathname)) {
      showUsersHome({ section: 'network' })
    }
  },
  showPublicHome () {
    const pathname = 'users/public'
    app.navigate(pathname)
    if (reqres.request('require:loggedIn', pathname)) {
      showUsersHome({ section: 'public' })
    }
  },
  showUserProfile,
  showUserInventory,
  showUserListings,
  showUserFollowers,
  showUserItemsByEntity (username, uri) {
    commands.execute('show:user:items:by:entity', username, uri)
  },
  showUserContributionsFromRoute (idOrUsername) {
    const filter = getQuerystringParameter('filter')
    showUserContributions(idOrUsername, isString(filter) ? filter : undefined)
  },
  showLatestUsers,
}

interface ShowUsersHome {
  user?: User | UserId | Username | UserAccountUri | SerializedUser | SerializedLoggedInMainUser
  group?: Group | GroupId | GroupSlug
  section?: 'public' | 'network'
  profileSection?: 'inventory' | 'listings'
}

export async function showUsersHome ({ user, group, section, profileSection }: ShowUsersHome) {
  try {
    const { default: UsersHomeLayout } = await import('#users/components/users_home_layout.svelte')
    const props = {
      section,
      profileSection,
      user: user ? await resolveToUser(user) : undefined,
      group: group ? await resolveToGroup(group) : undefined,
    }
    appLayout.showChildComponent('main', UsersHomeLayout, { props })
  } catch (err) {
    commands.execute('show:error', err)
  }
}

async function showUserContributions (userAcctOrIdOrUsername: string, filter: string) {
  try {
    const userAcct = await resolveToUserAcct(userAcctOrIdOrUsername)
    await showUserContributionsFromAcct(userAcct, filter)
  } catch (err) {
    commands.execute('show:error', err)
  }
}

export async function showUserContributionsFromAcct (userAcct: UserAccountUri, filter?: string) {
  try {
    const contributor = await getUserByAcct(userAcct)
    const { username, contributionsPathname, acct } = contributor
    let path = contributionsPathname
    if (filter) path += `?filter=${filter}`
    const title = i18n('contributions_by', { username: username || acct })
    app.navigate(path, { metadata: { title } })
    const { default: Contributions } = await import('#entities/components/patches/contributions.svelte')
    appLayout.showChildComponent('main', Contributions, { props: { contributor, filter } })
  } catch (err) {
    commands.execute('show:error', err)
  }
}

async function showUserFollowers (idOrUsername: UserId | Username) {
  try {
    const [
      { default: UsersHomeLayout },
      user,
    ] = await Promise.all([
      import('#users/components/users_home_layout.svelte'),
      resolveToUser(idOrUsername),
    ])
    appLayout.showChildComponent('main', UsersHomeLayout, {
      props: {
        showUserFollowers: true,
        user,
        actorName: user.username,
      },
    })
  } catch (err) {
    commands.execute('show:error', err)
  }
}

async function resolveToUserAcct (userAcctOrIdOrUsername: UserAccountUri | UserId | Username) {
  if (isUserAcct(userAcctOrIdOrUsername)) {
    return userAcctOrIdOrUsername
  } else if (isUserId(userAcctOrIdOrUsername)) {
    return getLocalUserAccount(userAcctOrIdOrUsername)
  } else {
    const user = await getUserByUsername(userAcctOrIdOrUsername)
    if (!user.anonymizableId) {
      throw newError("This user's contributions are private", 403, { username: userAcctOrIdOrUsername })
    }
    return getLocalUserAccount(user.anonymizableId)
  }
}
