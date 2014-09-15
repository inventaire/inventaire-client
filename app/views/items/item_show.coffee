module.exports =  class ItemShow extends Backbone.Marionette.LayoutView
  template: require 'views/items/templates/item_show'
  serializeData: -> @model.serializeData()
  regions:
    entityRegion: '#entity'

  onShow: ->
    entity = @model.get 'entity'
    if entity?.id?
      app.execute 'show:entity', entity.id, null, @entityRegion

