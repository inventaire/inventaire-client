import assert_ from '#lib/assert_types'
import { isModel, isShelfId } from '#lib/boolean_tests'
import error_ from '#lib/error'
import { getById, getShelfMetadata } from './lib/shelves.ts'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'shelves/without(/)': 'showItemsWithoutShelf',
        'shelves(/)(:id)(/)': 'showShelfFromId',
        // Redirection
        'shelf(/)(:id)(/)': 'showShelfFromId',
      },
    })

    new Router({ controller: API })

    app.commands.setHandlers({
      'show:shelf': showShelf,
    })
  },
}

async function showShelfFromId (shelfId) {
  try {
    assert_.string(shelfId)
    const shelf = await getById(shelfId)
    if (shelf != null) {
      return showShelf(shelf)
    } else {
      throw error_.new('not found', 404, { shelfId })
    }
  } catch (err) {
    app.execute('show:error', err)
  }
}

const API = {
  showShelfFromId,

  async showItemsWithoutShelf () {
    const pathname = 'shelves/without'
    if (app.request('require:loggedIn', pathname)) {
      const { default: UsersHomeLayout } = await import('#users/components/users_home_layout.svelte')
      // Passing shelf to display items and passing owner for user profile info
      app.layout.showChildComponent('main', UsersHomeLayout, {
        props: {
          user: app.user.toJSON(),
          shelf: 'without-shelf',
        },
      })
      app.navigate('shelves/without')
    }
  },
}

async function showShelf (shelf) {
  if (isShelfId(shelf)) return API.showShelfFromId(shelf)
  if (isModel(shelf)) shelf = shelf.toJSON()
  const { owner } = shelf
  const [
    { default: UsersHomeLayout },
    user,
  ] = await Promise.all([
    import('#users/components/users_home_layout.svelte'),
    app.request('resolve:to:user', owner),
  ])
  // Passing shelf to display items and passing owner for user profile info
  app.layout.showChildComponent('main', UsersHomeLayout, {
    props: {
      shelf,
      user,
    },
  })
  const metadata = getShelfMetadata(shelf)
  const { url: pathname } = metadata
  app.navigate(pathname, { metadata })
}
