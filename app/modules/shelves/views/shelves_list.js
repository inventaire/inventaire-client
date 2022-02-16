import { isOpenedOutside } from '#lib/utils'
import shelvesListLiTemplate from './templates/shelves_list_li.hbs'
import '../scss/shelves_list.scss'
import PreventDefault from '#behaviors/prevent_default'

const ListEl = Marionette.View.extend({
  tagName: 'li',
  template: shelvesListLiTemplate,

  behaviors: {
    PreventDefault,
  },

  events: {
    'click .selectShelf': 'selectShelf'
  },

  modelEvents: {
    change: 'lazyRender'
  },

  selectShelf (e) {
    if (isOpenedOutside(e)) return
    const type = this.model.get('type')
    app.vent.trigger('inventory:select', type, this.model)
    e.preventDefault()
  }
})

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: ListEl
})
