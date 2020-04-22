ListEl = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/shelves_list_li'

  behaviors:
    PreventDefault: {}

  events:
    'click a': 'selectInventory'

  selectInventory: (e)->
    if _.isOpenedOutside e then return
    type = @model.get('type')
    app.vent.trigger 'inventory:select', type, @model
    e.preventDefault()

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ListEl
