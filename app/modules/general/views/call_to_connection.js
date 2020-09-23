/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const { banner } = require('lib/urls').images

export default Marionette.ItemView.extend({
  template: require('./templates/call_to_connection'),
  onShow () { return app.execute('modal:open') },
  serializeData () {
    return _.extend(this.options,
      { banner })
  },

  events: {
    // login buttons events are handled from the login plugin
    // but we still need to close the modal from here
    'click a' () { return app.execute('modal:close') }
  }
})
