import { isOpenedOutside } from 'lib/utils'
import previousSearchTemplate from './templates/previous_search.hbs'

export default Marionette.ItemView.extend({
  template: previousSearchTemplate,
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
    if (!isOpenedOutside(e)) return this.model.show()
  }
})
