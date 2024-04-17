import app from '#app/app'
import { scrollTo$Element, viewportIsSmall } from '#app/lib/screen'
import PreventDefault from '#behaviors/prevent_default'
import { I18n } from '#user/lib/i18n'
import tabsData from './lib/add_layout_tabs.ts'
import addLayoutTemplate from './templates/add_layout.hbs'
import '#inventory/scss/add_layout.scss'

export default Marionette.View.extend({
  template: addLayoutTemplate,
  id: 'addLayout',

  regions: {
    content: '.custom-tabs-content',
  },

  ui: {
    tabs: '.tab',
    searchTab: '#searchTab',
    scanTab: '#scanTab',
    importTab: '#importTab',
  },

  initialize () {
    this.loggedIn = app.user.loggedIn
  },

  serializeData () {
    return {
      loggedIn: this.loggedIn,
      tabs: tabsData,
    }
  },

  behaviors: {
    PreventDefault,
  },

  events: {
    'click .tab': 'changeTab',
  },

  onRender () {
    if (this.loggedIn) {
      this.showTabView(this.options.tab)
    } else {
      const msg = 'you need to be connected to add a book to your inventory'
      app.execute('show:call:to:connection', msg)
    }
  },

  onDestroy () {
    if (!this.loggedIn) {
      app.execute('modal:close')
    }
  },

  async showTabView (tab) {
    const { wait, View } = tabsData[tab]
    const tabKey = `${tab}Tab`
    if (wait) await wait
    if (tab === 'import') {
      const { default: SvelteImportLayout } = await import('#inventory/components/importer/import_layout.svelte')
      this.showChildComponent('content', SvelteImportLayout, {
        props: {
          isbns: this.options.isbns,
        },
      })
    } else {
      this.showChildView('content', new View(this.options))
    }
    this.ui.tabs.removeClass('active')
    this.ui[tabKey].addClass('active')
    app.navigate(`add/${tab}`, {
      metadata: {
        title: I18n(`title_add_layout_${tab}`),
      },
    })
  },

  changeTab (e) {
    const tab = e.currentTarget.id.split('Tab')[0]
    this.showTabView(tab)
    const contentEl: JQuery = this.getRegion('content').$el
    if (viewportIsSmall() && contentEl.position()) {
      scrollTo$Element({ $el: contentEl })
    }
  },
})
