import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import { getGroupBySlug, mainUserIsGroupMember, serializeGroup } from '#groups/lib/groups'
import type { Group, GroupSlug } from '#server/types/group'
import { mainUser } from '#user/lib/main_user'
import { showUsersHome } from '#users/users'
import { getUserGroups } from './lib/groups_data.ts'

export default {
  initialize () {
    addRoutes({
      '/g(roups)/:id(/)': 'showGroupProfile',
      '/g(roups)/:id/inventory(/)': 'showGroupInventory',
      '/g(roups)/:id/lists(/)': 'showGroupListings',
      '/g(roups)/:id/settings(/)': 'showGroupBoard',
      '/g(roups)(/)': 'showNetworkLayout',

      // Legacy redirections
      '/network/groups/create(/)': 'showCreateGroupLayout',
      '/network/groups/settings/:id(/)': 'showGroupBoard',
    }, controller)

    commands.setHandlers({
      'show:group:board': showGroupBoardFrom,
    })

    if (mainUser.loggedIn) getUserGroups()
  },
}

const controller = {
  showGroupProfile (slug: GroupSlug) {
    return showUsersHome({ group: slug })
  },
  showGroupInventory (slug: GroupSlug) {
    return showUsersHome({ group: slug, profileSection: 'inventory' })
  },
  showGroupListings (slug: GroupSlug) {
    return showUsersHome({ group: slug, profileSection: 'listings' })
  },
  // Named showGroupBoard and not showGroupSettings
  // as GroupSettings are a child component of GroupBoard
  showGroupBoard (slug: GroupSlug) {
    const pathname = `groups/${slug}/settings`
    if (reqres.request('require:loggedIn', pathname)) {
      return showGroupBoard(slug)
    }
  },

  async showCreateGroupLayout () {
    const { default: CreateGroup } = await import('#groups/components/create_group.svelte')
    appLayout.showChildComponent('modal', CreateGroup)
  },

  showNetworkLayout () {
    commands.execute('show:inventory:network')
  },
} as const

async function showGroupBoard (slug: GroupSlug) {
  try {
    let group = await getGroupBySlug(slug)
    if (mainUserIsGroupMember(group)) {
      group = serializeGroup(group)
      const { default: GroupBoard } = await import('#groups/components/group_board.svelte')
      appLayout.showChildComponent('main', GroupBoard, { props: { group } })
      app.navigate(group.settingsPathname)
    } else {
      controller.showGroupInventory(slug)
    }
  } catch (err) {
    commands.execute('show:error', err)
  }
}

async function showGroupBoardFrom (doc: Group) {
  return showGroupBoard(doc.slug)
}
