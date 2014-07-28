module.exports = class BookLi extends Backbone.Marionette.ItemView
  template: require 'views/items/templates/book_li'
  tagName: "div"
  className: "book panel row"
  serializeData: ->
    return @model