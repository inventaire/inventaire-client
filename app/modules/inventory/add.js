/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import AddLayout from './views/add/add_layout'
import initAddHelpers from './lib/add_helpers'
import EmbeddedScanner from './views/add/embedded_scanner'

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'add(/search)(/)': 'showSearch',
        'add/scan(/)': 'showScan',
        'add/scan/embedded(/)': 'showEmbeddedScanner',
        'add/import(/)': 'showImport'
      }
    })

    return app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    initAddHelpers()
    return initializeHandlers()
  }
}

var API = {
  showSearch () { return showAddLayout('search') },
  showScan () { return showAddLayout('scan') },
  showImport () { return showAddLayout('import') },
  showEmbeddedScanner () {
    if (app.request('require:loggedIn', 'add/scan/embedded')) {
      if (window.hasVideoInput) {
        // navigate before triggering the view itself has
        // special behaviors on route change
        app.navigate('add/scan/embedded')
        // showing in main so that requesting another layout destroy this view
        return app.layout.main.show(new EmbeddedScanner())
      } else {
        return API.showScan()
      }
    }
  }
}

var showAddLayout = function (tab = 'search', options = {}) {
  if (app.request('require:loggedIn', `add/${tab}`)) {
    options.tab = tab
    return app.layout.main.show(new AddLayout(options))
  }
}

var initializeHandlers = () => app.commands.setHandlers({
  'show:add:layout': showAddLayout,
  // equivalent to the previous one as long as search is the default tab
  // but more explicit
  'show:add:layout:search': API.showSearch,

  'show:add:layout:import:isbns' (isbnsBatch) {
    return showAddLayout('import', { isbnsBatch })
  },

  'show:scan': API.showScan,

  'show:scanner:embedded': API.showEmbeddedScanner
})
