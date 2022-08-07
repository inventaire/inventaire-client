import { getListWithSelectionsById } from './lib/lists.js'

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

async function showMainUserLists () {
  const { default: ListsLayout } = await import('./components/user_lists.svelte')
  try {
    app.layout.showChildComponent('main', ListsLayout, {
      props: {
        user: app.user.toJSON()
      }
    })
  } catch (err) {
    app.execute('show:error', err)
  }
}

const API = {
  showList,
  showMainUserLists
}
