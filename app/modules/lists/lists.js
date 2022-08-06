import { getListWithSelectionsById } from './lib/lists.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'lists/(:id)(/)': 'showList',
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

const showList = async id => {
  const { default: ListLayout } = await import('./components/lists_layout.svelte')
  try {
    const list = await getListWithSelectionsById(id)
    app.layout.showChildComponent('main', ListLayout, {
      props: { list }
    })
  } catch (err) {
    app.execute('show:error', err)
  }
}
