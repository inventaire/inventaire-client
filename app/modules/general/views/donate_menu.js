import { donate } from '#lib/urls'
import donateMenuTemplate from './templates/donate_menu.hbs'
import '../scss/donate.scss'
import General from '#behaviors/general'

export default Marionette.View.extend({
  template: donateMenuTemplate,
  className () {
    const standalone = this.options.standalone ? 'standalone' : ''
    return `donate-menu ${standalone}`
  },

  initialize () {
    this.standalone = this.options.standalone
  },

  behaviors: {
    General,
  },

  onRender () { if (!this.standalone) { app.execute('modal:open') } },

  serializeData () { return _.extend(donate, { standalone: this.standalone }) }
})
