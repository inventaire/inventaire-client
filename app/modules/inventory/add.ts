import app from '#app/app'
import { getDevicesInfo } from '#app/lib/has_video_input'
import { getQuerystringParameter } from '#app/lib/querystring_helpers'
import { addRoutes } from '#app/lib/router'

export default {
  initialize () {
    addRoutes({
      '/add(/search)(/)': 'showSearch',
      '/add/scan(/)': 'showScan',
      '/add/scan/embedded(/)': 'showEmbeddedScanner',
      '/add/import(/)': 'showImport',
    }, controller)

    initializeHandlers()
  },
}

const controller = {
  showSearch () {
    showAddLayout('search')
  },
  showScan () {
    showAddLayout('scan')
  },
  showImport () {
    const isbnsStr = getQuerystringParameter('isbns')
    const isbns = typeof isbnsStr === 'string' ? isbnsStr.split('|') : undefined
    showAddLayout('import', { isbns })
  },
  async showEmbeddedScanner () {
    if (app.request('require:loggedIn', 'add/scan/embedded')) {
      if (getDevicesInfo().hasVideoInput) {
        // navigate before triggering the view itself has
        // special behaviors on route change
        app.navigate('add/scan/embedded')
        const { default: EmbeddedScanner } = await import('./components/add/embedded_scanner.svelte')
        // showing in main so that requesting another layout destroy this view
        app.layout.showChildComponent('main', EmbeddedScanner)
      } else {
        controller.showScan()
      }
    }
  },
} as const

interface AddLayoutOptions {
  isbns?: string[]
}
async function showAddLayout (tab = 'search', options: AddLayoutOptions = {}) {
  if (app.request('require:loggedIn', `add/${tab}`)) {
    const { default: AddLayout } = await import('./components/add/add_layout.svelte')
    app.layout.showChildComponent('main', AddLayout, {
      props: {
        tab,
        ...options,
      },
    })
  }
}

const initializeHandlers = () => app.commands.setHandlers({
  'show:add:layout': showAddLayout,
  // equivalent to the previous one as long as search is the default tab
  // but more explicit
  'show:add:layout:search': controller.showSearch,

  'show:add:layout:import:isbns' (isbns: string[]) {
    showAddLayout('import', { isbns })
  },

  'show:scan': controller.showScan,

  'show:scanner:embedded': controller.showEmbeddedScanner,
})
