BookLi = require 'views/items/book_li'

module.exports = class Book extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/book'
  behaviors:
    Loading: {}
  events:
    'click #isbnButton': 'isbnSearch'

  isbnSearch: (e)->
    e.preventDefault()
    @$el.trigger 'loading'
    query = $('#isbn').val()
    if query.trim().length > 9
      $.getJSON "#{app.API.entities.search}?isbn=#{query}"
      .then (res)=>
        _.log res, 'res'
        bookLi = new BookLi {model: res}
        app.layout.item.creation.preview.show bookLi
        @$el.trigger 'stopLoading'
    else
      _.log 'invalid request'