import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { assertString } from '#app/lib/assert_types'
import { isShelfId } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import type { Shelf, ShelfId } from '#server/types/shelf'
import { mainUser } from '#user/lib/main_user'
import { resolveToUser } from '../users/users_data.ts'
import { getShelfById, getShelfMetadata } from './lib/shelves.ts'

export default {
  initialize () {
    addRoutes({
      '/shelves/without(/)': 'showItemsWithoutShelf',
      '/shelves/(:id)/followers(/)': 'showShelfFollowers',
      '/shelves(/)(:id)(/)': 'showShelfFromId',
      // Redirection
      '/shelf(/)(:id)(/)': 'showShelfFromId',
    }, controller)
  },
}

async function showShelfFromId (shelfId: ShelfId) {
  try {
    assertString(shelfId)
    const shelf = await getShelfById(shelfId)
    if (shelf != null) {
      return showShelf(shelf)
    } else {
      throw newError('not found', 404, { shelfId })
    }
  } catch (err) {
    commands.execute('show:error', err)
  }
}

const controller = {
  showShelfFromId,
  showShelfFollowers,
  async showItemsWithoutShelf () {
    const pathname = 'shelves/without'
    if (reqres.request('require:loggedIn', pathname)) {
      const { default: UsersHomeLayout } = await import('#users/components/users_home_layout.svelte')
      // Passing shelf to display items and passing owner for user profile info
      appLayout.showChildComponent('main', UsersHomeLayout, {
        props: {
          user: mainUser,
          shelf: 'without-shelf',
        },
      })
      app.navigate('shelves/without')
    }
  },
} as const

export async function showShelf (shelf: ShelfId | Shelf) {
  if (isShelfId(shelf)) return controller.showShelfFromId(shelf)
  const { owner } = shelf
  const [
    { default: UsersHomeLayout },
    user,
  ] = await Promise.all([
    import('#users/components/users_home_layout.svelte'),
    resolveToUser(owner),
  ])
  // Passing shelf to display items and passing owner for user profile info
  appLayout.showChildComponent('main', UsersHomeLayout, {
    props: {
      shelf,
      user,
    },
  })
  const metadata = getShelfMetadata(shelf)
  const { url: pathname } = metadata
  app.navigate(pathname, { metadata })
}

async function showShelfFollowers (shelfId) {
  try {
    const [
      { default: UsersHomeLayout },
      shelf,
    ] = await Promise.all([
      import('#users/components/users_home_layout.svelte'),
      getShelfById(shelfId),
    ])
    const user = await resolveToUser(shelf.owner)
    appLayout.showChildComponent('main', UsersHomeLayout, {
      props: {
        shelf,
        user,
        showShelfFollowers: true,
      },
    })
  } catch (err) {
    commands.execute('show:error', err)
  }
}
