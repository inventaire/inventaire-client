import { donate } from 'lib/urls'
// import Marionette from 'backbone.marionette'

export default Marionette.ItemView.extend({
  template: require('./templates/donate_menu.hbs'),
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
