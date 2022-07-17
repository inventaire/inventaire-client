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
  const { default: SettingsLayout } = await import('./components/lists_layout.svelte')
  return app.layout.showChildComponent('main', SettingsLayout, {
    props: { id }
  })
}
