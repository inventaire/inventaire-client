module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'imported-item-row'
  template: require './templates/imported_item_row'
  serializeData: ->
    attrs = @model.serializeData()
    [ prefix, id ] = attrs.entity.split ':'
    if prefix is 'isbn' then attrs.isbn = id
    return attrs

  events:
    'click .showItem': 'showItem'

  showItem: ->
    app.execute 'show:item', @model
