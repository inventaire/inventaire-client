import { donate } from 'lib/urls'
import donateMenuTemplate from './templates/donate_menu.hbs'

// import Marionette from 'backbone.marionette'

export default Marionette.ItemView.extend({
  template: donateMenuTemplate,
  className () {
    const standalone = this.options.standalone ? 'standalone' : ''
    return `donate-menu ${standalone}`
  },

  initialize () {
    return ({ standalone: this.standalone } = this.options)
  },

  behaviors: {
    General: {}
  },

  onShow () { if (!this.standalone) { app.execute('modal:open') } },

  serializeData () { return _.extend(donate, { standalone: this.standalone }) }
})
