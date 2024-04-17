import { isOpenedOutside } from '#app/lib/utils'
import PreventDefault from '#behaviors/prevent_default'
import previousSearchTemplate from './templates/previous_search.hbs'

export default Marionette.View.extend({
  template: previousSearchTemplate,
  tagName: 'li',
  className: 'previous-search',
  behaviors: {
    PreventDefault,
  },

  serializeData () { return this.model.serializeData() },

  events: {
    'click a': 'showSearch',
  },

  showSearch (e) {
    if (!isOpenedOutside(e)) return this.model.show()
  },
})
