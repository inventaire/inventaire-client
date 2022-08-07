import { getListsByCreator, getListWithSelectionsById } from './lib/lists.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'lists/(:id)(/)': 'showList',
        'lists(/)': 'showMainUserLists'
      }
    })

    new Router({ controller: API })
  },
}

const API = {
  async showList (id) {
    showList(id)
  },
}

async function showList (id) {
  const { default: ListLayout } = await import('./components/list_layout.svelte')
  try {
    const { list, selections } = await getListWithSelectionsById(id)
    app.layout.showChildComponent('main', ListLayout, {
      props: { list, selections }
    })
  } catch (err) {
    app.execute('show:error', err)
  }
}
