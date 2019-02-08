module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'item-row'
  template: require './templates/item_row'

  serializeData: -> @model.serializeData()
