import { donate } from 'lib/urls'

export default Marionette.ItemView.extend({
  template: require('./templates/donate_menu'),
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
