import error_ from 'lib/error'
import { isShelfId } from 'lib/boolean_tests'
import ShelfModel from './models/shelf'
import { getById } from './lib/shelves'

export default {
  define () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'shelves(/)(:id)(/)': 'showShelfFromId',
        // Redirection
        'shelf(/)(:id)(/)': 'showShelfFromId'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    app.commands.setHandlers({
      'show:shelf': showShelf
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
  }
}

const showShelf = function (shelf) {
  if (isShelfId(shelf)) {
    return API.showShelfFromId(shelf)
  } else {
    return showShelfFromModel(shelf)
  }
}

const showShelfFromModel = async shelf => {
  const { default: InventoryLayout } = await import('../inventory/views/inventory_layout')
  const owner = shelf.get('owner')
  // Passing shelf to display items and passing owner for user profile info
  app.layout.main.show(new InventoryLayout({
    shelf,
    user: owner,
    standalone: true
  }))
  app.navigateFromModel(shelf)
}
