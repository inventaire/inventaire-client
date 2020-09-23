/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.ItemView.extend({
  className: 'version',
  template: require('./templates/version'),
  initialize () {},

  serializeData () { return this.model.serializeData() },

  modelEvents: {
    grab: 'lazyRender'
  }
})
