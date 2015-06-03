module.exports = Backbone.NestedModel.extend
  initialize: ->
    @on 'change:status', @update
    if @get('data.item')?
      app.request('waitForItems').then @getItemData.bind(@)

  update: ->
    @collection.updateStatus @get('time')

  getItemData: ->
    app.request 'get:item:model', @get('data.item')
    .then @setItemModel.bind(@)
    .catch _.Error('getItemData')

  setItemModel: (itemModel)->
    @item = itemModel
    @set 'item', itemModel.toJSON()
