import initAddHelpers from './lib/add_helpers'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'add(/search)(/)': 'showSearch',
        'add/scan(/)': 'showScan',
        'add/scan/embedded(/)': 'showEmbeddedScanner',
        'add/import(/)': 'showImport'
      }
    })

    new Router({ controller: API })

    initAddHelpers()
    initializeHandlers()
  }
}

const API = {
  showSearch () {
    showAddLayout('search')
  },
  showScan () {
    showAddLayout('scan')
  },
  showImport () {
    showAddLayout('import')
  },
  async showEmbeddedScanner () {
    if (app.request('require:loggedIn', 'add/scan/embedded')) {
      if (window.hasVideoInput) {
        // navigate before triggering the view itself has
        // special behaviors on route change
        app.navigate('add/scan/embedded')
        const { default: EmbeddedScanner } = await import('./views/add/embedded_scanner')
        // showing in main so that requesting another layout destroy this view
        app.layout.showChildView('main', new EmbeddedScanner())
      } else {
        API.showScan()
      }
    }
  }
}

const showAddLayout = async (tab = 'search', options = {}) => {
  if (app.request('require:loggedIn', `add/${tab}`)) {
    options.tab = tab
    const { default: AddLayout } = await import('./views/add/add_layout')
    app.layout.showChildView('main', new AddLayout(options))
  }
}

const initializeHandlers = () => app.commands.setHandlers({
  'show:add:layout': showAddLayout,
  // equivalent to the previous one as long as search is the default tab
  // but more explicit
  'show:add:layout:search': API.showSearch,

  'show:add:layout:import:isbns' (isbnsBatch) {
    showAddLayout('import', { isbnsBatch })
  },

  'show:scan': API.showScan,

  'show:scanner:embedded': API.showEmbeddedScanner
})
