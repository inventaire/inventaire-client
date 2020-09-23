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
