/* eslint-disable
    import/no-duplicates,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
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

  onShow () { if (!this.standalone) { return app.execute('modal:open') } },

  serializeData () { return _.extend(donate, { standalone: this.standalone }) }
})
