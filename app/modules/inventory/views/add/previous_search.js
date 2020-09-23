/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default Marionette.ItemView.extend({
  template: require('./templates/previous_search'),
  tagName: 'li',
  className: 'previous-search',
  behaviors: {
    PreventDefault: {}
  },

  serializeData () { return this.model.serializeData() },

  events: {
    'click a': 'showSearch'
  },

  showSearch (e) {
    if (!_.isOpenedOutside(e)) { return this.model.show() }
  }
})
