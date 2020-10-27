import { donate } from 'lib/urls'
import donateMenuTemplate from './templates/donate_menu.hbs'
import '../scss/donate.scss'

export default Marionette.ItemView.extend({
  template: donateMenuTemplate,
  className () {
    const standalone = this.options.standalone ? 'standalone' : ''
    return `donate-menu ${standalone}`
  },

  initialize () {
    ({ standalone: this.standalone } = this.options)
  },

  behaviors: {
    General: {}
  },

  onShow () { if (!this.standalone) { app.execute('modal:open') } },

  serializeData () { return _.extend(donate, { standalone: this.standalone }) }
})
