import tabsData from 'modules/inventory/lib/add_layout_tabs'
import screen_ from 'lib/screen'

export default Marionette.LayoutView.extend({
  template: require('./templates/add_layout'),
  id: 'addLayout',

  regions: {
    content: '.custom-tabs-content'
  },

  ui: {
    tabs: '.tab',
    searchTab: '#searchTab',
    scanTab: '#scanTab',
    importTab: '#importTab'
  },

  initialize () {
    return this.loggedIn = app.user.loggedIn
  },

  serializeData () {
    return {
      loggedIn: this.loggedIn,
      tabs: tabsData
    }
  },

  behaviors: {
    PreventDefault: {}
  },

  events: {
    'click .tab': 'changeTab'
  },

  onShow () {
    if (this.loggedIn) {
      return this.showTabView(this.options.tab)
    } else {
      const msg = 'you need to be connected to add a book to your inventory'
      return app.execute('show:call:to:connection', msg)
    }
  },

  onDestroy () {
    if (!this.loggedIn) {
      return app.execute('modal:close')
    }
  },

  showTabView (tab) {
    const View = require(`./${tab}`)
    const tabKey = `${tab}Tab`
    const wait = tabsData[tab].wait || Promise.resolve()

    return wait
    .then(() => {
      this.content.show(new View(this.options))
      this.ui.tabs.removeClass('active')
      this.ui[tabKey].addClass('active')
      return app.navigate(`add/${tab}`,
        { metadata: { title: _.I18n(`title_add_layout_${tab}`) } })
    })
  },

  changeTab (e) {
    const tab = e.currentTarget.id.split('Tab')[0]
    this.showTabView(tab)
    if (screen_.isSmall()) { return screen_.scrollTop(this.content.$el) }
  }
})
