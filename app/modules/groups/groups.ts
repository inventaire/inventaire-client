import app from '#app/app'
import { getGroupBySlug, mainUserIsGroupMember, serializeGroup } from '#groups/lib/groups'
import type { Group, GroupSlug } from '#server/types/group'
import { showUsersHome } from '#users/users'
import { getUserGroups } from './lib/groups_data.ts'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'g(roups)/:id(/)': 'showGroupProfile',
        'g(roups)/:id/inventory(/)': 'showGroupInventory',
        'g(roups)/:id/lists(/)': 'showGroupListings',
        'g(roups)/:id/settings(/)': 'showGroupBoard',
        'g(roups)(/)': 'showNetworkLayout',

        // Legacy redirections
        'network/groups/create(/)': 'showCreateGroupLayout',
        'network/groups/settings/:id(/)': 'showGroupBoard',
      },
    })

    new Router({ controller })

    app.commands.setHandlers({
      'show:group:board': showGroupBoardFrom,
    })

    if (app.user.loggedIn) getUserGroups()
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
    if (app.request('require:loggedIn', pathname)) {
      return showGroupBoard(slug)
    }
  },

  async showCreateGroupLayout () {
    const { default: CreateGroup } = await import('#groups/components/create_group.svelte')
    app.layout.showChildComponent('modal', CreateGroup)
  },

  showNetworkLayout () {
    app.execute('show:inventory:network')
  },
}

async function showGroupBoard (slug: GroupSlug) {
  try {
    let group = await getGroupBySlug(slug)
    if (mainUserIsGroupMember(group)) {
      group = serializeGroup(group)
      const { default: GroupBoard } = await import('#groups/components/group_board.svelte')
      app.layout.showChildComponent('main', GroupBoard, { props: { group } })
      app.navigate(group.settingsPathname)
    } else {
      controller.showGroupInventory(slug)
    }
  } catch (err) {
    app.execute('show:error', err)
  }
}

async function showGroupBoardFrom (doc: Group) {
  return showGroupBoard(doc.slug)
}
