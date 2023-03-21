import error_ from '#lib/error'
import { isModel, isShelfId } from '#lib/boolean_tests'
import ShelfModel from './models/shelf.js'
import { getById } from './lib/shelves.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'shelves/without(/)': 'showItemsWithoutShelf',
        'shelves(/)(:id)(/)': 'showShelfFromId',
        // Redirection
        'shelf(/)(:id)(/)': 'showShelfFromId'
      }
    })

    new Router({ controller: API })

    app.commands.setHandlers({
      'show:shelf': showShelf,
      'show:shelf:editor': showShelfEditor,
      'add:items:to:shelf': addItemsToShelf,
    })
  }
}

const API = {
  showShelfFromId (shelfId) {
    if (shelfId == null) return app.execute('show:inventory:main:user')

    return getById(shelfId)
    .then(shelf => {
      if (shelf != null) {
        const model = new ShelfModel(shelf)
        return showShelfFromModel(model)
      } else {
        throw error_.new('not found', 404, { shelfId })
      }
    })
    .catch(app.Execute('show:error'))
  },

  async showItemsWithoutShelf () {
    const pathname = 'shelves/without'
    if (app.request('require:loggedIn', pathname)) {
      const { default: UsersHomeLayout } = await import('#users/components/users_home_layout.svelte')
      // Passing shelf to display items and passing owner for user profile info
      app.layout.showChildComponent('main', UsersHomeLayout, {
        props: {
          user: app.user.toJSON(),
          withoutShelf: true,
          standalone: true,
        }
      })
      app.navigate('shelves/without')
    }
  },
}

const showShelf = function (shelf) {
  if (isShelfId(shelf)) {
    API.showShelfFromId(shelf)
  } else {
    if (!isModel(shelf)) shelf = new ShelfModel(shelf)
    showShelfFromModel(shelf)
  }
}

const showShelfFromModel = async shelf => {
  const { default: UsersHomeLayout } = await import('#users/components/users_home_layout.svelte')
  const owner = shelf.get('owner')
  const user = await app.request('resolve:to:user', owner)
  // Passing shelf to display items and passing owner for user profile info
  app.layout.showChildComponent('main', UsersHomeLayout, {
    props: {
      shelf: shelf.toJSON(),
      user,
      standalone: true
    }
  })
  app.navigateFromModel(shelf)
}

const addItemsToShelf = async shelf => {
  const { default: ShelfItemsAdder } = await import('#shelves/views/shelf_items_adder')
  const model = new ShelfModel(shelf)
  app.layout.showChildView('modal', new ShelfItemsAdder({ model }))
}

const showShelfEditor = async shelf => {
  const { default: ShelfEditor } = await import('#shelves/components/shelf_editor.svelte')
  const model = new ShelfModel(shelf)
  app.layout.showChildComponent('modal', ShelfEditor, {
    props: {
      shelf,
      model,
    }
  })
}
