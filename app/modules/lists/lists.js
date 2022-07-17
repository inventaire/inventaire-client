import { getListWithSelectionsById } from './lib/lists.js'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'lists/:id(/)': 'showList',
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
  const { default: ListLayout } = await import('./components/list_layout.svelte')
  return getListWithSelectionsById(id)
  .then(list => {
    return app.layout.showChildComponent('main', ListLayout, {
      props: { list }
    })
  })
  .catch(app.Execute('show:error'))
}
