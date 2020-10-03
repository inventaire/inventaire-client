import { isOpenedOutside } from 'lib/utils'
export default Marionette.ItemView.extend({
  template: require('./templates/previous_search.hbs'),
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
    if (!isOpenedOutside(e)) { return this.model.show() }
  }
})
