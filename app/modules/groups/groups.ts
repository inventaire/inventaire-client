import { getGroupBySlug, mainUserIsGroupMember, serializeGroup } from '#groups/lib/groups'
import { isModel } from '#lib/boolean_tests'
import fetchData from '#lib/data/fetch'
import { showUsersHome } from '#users/users'
import Groups from './collections/groups.ts'
import initGroupHelpers from './lib/group_helpers.ts'

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

    new Router({ controller: API })

    app.commands.setHandlers({
      'show:group:board': showGroupBoardFromDocOrModel,
      'create:group': API.showCreateGroupLayout,
    })

    fetchData({
      name: 'groups',
      Collection: Groups,
      condition: app.user.loggedIn,
    })

    return app.request('wait:for', 'user')
    .then(initGroupHelpers)
    .then(initRequestsCollectionsEvent.bind(this))
  },
}

const initRequestsCollectionsEvent = function () {
  if (app.user.loggedIn) {
    return app.request('waitForNetwork')
    .then(() => app.vent.trigger('network:requests:update'))
  }
}

const API = {
  showGroupProfile (slug) {
    return showUsersHome({ group: slug })
  },
  showGroupInventory (slug) {
    return showUsersHome({ group: slug, profileSection: 'inventory' })
  },
  showGroupListings (slug) {
    return showUsersHome({ group: slug, profileSection: 'listings' })
  },
  // Named showGroupBoard and not showGroupSettings
  // as GroupSettings are a child view of GroupBoard
  showGroupBoard (slug) {
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

async function showGroupBoard (slug) {
  try {
    let group = await getGroupBySlug(slug)
    if (mainUserIsGroupMember(group)) {
      group = serializeGroup(group)
      const { default: GroupBoard } = await import('#groups/components/group_board.svelte')
      app.layout.showChildComponent('main', GroupBoard, { props: { group } })
      app.navigate(group.settingsPathname)
    } else {
      API.showGroupInventory(slug)
    }
  } catch (err) {
    app.execute('show:error', err)
  }
}

async function showGroupBoardFromDocOrModel (docOrModel) {
  const slug = isModel(docOrModel) ? docOrModel.get('slug') : docOrModel.slug
  return showGroupBoard(slug)
}
