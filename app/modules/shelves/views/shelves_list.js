const ListEl = Marionette.ItemView.extend({
  tagName: 'li',
  template: require('./templates/shelves_list_li'),

  behaviors: {
    PreventDefault: {}
  },

  events: {
    'click .selectShelf': 'selectShelf'
  },

  modelEvents: {
    change: 'lazyRender'
  },

  selectShelf (e) {
    if (_.isOpenedOutside(e)) return
    const type = this.model.get('type')
    app.vent.trigger('inventory:select', type, this.model)
    return e.preventDefault()
  }
})

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  childView: ListEl
})
