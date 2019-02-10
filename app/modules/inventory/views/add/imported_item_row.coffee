module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'item-row'
  template: require './templates/imported_item_row'
  serializeData: ->
    attrs = @model.serializeData()
    [ prefix, id ] = attrs.entity.split ':'
    if prefix is 'isbn' then attrs.isbn = id
    return attrs

  events:
    'click .showItem': 'showItem'

  showItem: ->
    app.execute 'show:item:modal', @model
    @listenToOnce app.vent, 'route:change', app.Execute('modal:close')
