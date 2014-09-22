module.exports =  class ItemShow extends Backbone.Marionette.LayoutView
  template: require 'views/items/templates/item_show'
  serializeData: -> @model.serializeData()
  regions:
    entityRegion: '#entity'

  onShow: ->
    entity = @model.get 'entity'
    if entity?.id?
      # ugly null null, but it's constrained by the scanner callback
      # returning /entity/:uri/add?:params
      app.execute 'show:entity', entity.id, null, null, @entityRegion

  events:
    'click a.edit': 'editItem'

  editItem: -> app.execute 'show:item:form:edition', @model