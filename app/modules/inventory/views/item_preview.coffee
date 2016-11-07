module.exports = Marionette.ItemView.extend
  template: require './templates/item_preview'
  className: 'item-preview'
  behaviors:
    PreventDefault: {}
  serializeData: -> @model.serializeData()
  events:
    'click .showItem': 'showItem'

  showItem: -> app.execute 'show:item:show:from:model', @model
