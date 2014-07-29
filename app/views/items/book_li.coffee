module.exports = class BookLi extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/book_li'
  tagName: "div"
  className: "book panel row"
  events:
    'click #validPreview': 'addItem'
  addItem: ->
    _.log 'got here!'
    if app.request('item:validateCreation', @model.toJSON())
      @$el.trigger 'check', -> app.commands.execute 'modal:close'
    else
      console.error 'invalid item data'