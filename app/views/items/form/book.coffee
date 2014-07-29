BookLi = require 'views/items/book_li'

module.exports = class Book extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/book'
  behaviors:
    AlertBox: {}
    Loading: {}
    SuccessCheck: {}
  events:
    'keyup #titleInput': 'onKeyup'
    'keyup #authorInput': 'onKeyup'
    'keyup #isbnInput': 'onKeyup'
    'click #isbnButton': 'isbnSearch'

  onKeyup: (e)->
    _.log 'keyup'
    if @$el.find('.alert-box').is(':visible')
      @$el.trigger 'hideAlertBox'
    if e.keyCode is 13 && $(e.currentTarget).val().length isnt ''
      switch  e.currentTarget.id
        when 'titleInput' then @titleSearch(e)
        when 'authorInput' then @authorSearch(e)
        when 'isbnInput' then @isbnSearch(e)
    else
      _.log 'not enter'

  titleSearch: (e)->
    _.log 'titleSearch'

  authorSearch: (e)->
    _.log 'authorSearch'

  isbnSearch: (e)->
    query = $('#isbnInput').val()
    if query.trim().length > 9
      @$el.trigger 'loading', {selector: '#isbnButton'}
      $.getJSON "#{app.API.entities.search}?isbn=#{query}"
      .then (res)=>
        _.log res, 'res'
        @book = new Backbone.Model res
        bookLi = new BookLi {model: @book}
        app.layout.item.creation.preview.show bookLi
        @$el.trigger 'stopLoading', {selector: '#isbnButton'}
      .fail (err)=>
        @$el.trigger 'stopLoading', {selector: '#isbnButton'}
        @$el.trigger('alert', {selector: '#isbnInput', message: 'no item found'})
    else
      @$el.trigger('alert', {selector: '#isbnInput', message: 'invalid isbn'})
