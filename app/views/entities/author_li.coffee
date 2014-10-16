module.exports = class AuthorLi extends Backbone.Marionette.CompositeView
  template: require 'views/entities/templates/author_li'
  tagName: "li"
  className: "authorLi"
  behaviors:
    Loading: {}

  childViewContainer: '.authorsBooks'
  childView: require 'views/entities/book_li'

  initialize: (options)->
    @collection = new Backbone.Collection
    if options.displayBooks then @onShow = @displayBooks

  events:
    'click a#displayBooks': 'displayBooks'

  displayBooks: ->
    @fetchBooks()
    @$el.trigger 'loading'
    @$el.find('#displayBooks').toggle()

  fetchBooks: ->
    @model.fetchAuthorsBooks()
    .then (models)=>
      @$el.trigger 'stopLoading'
      if models?
        models.forEach (model)=> @collection.add(model)
      else 'no book found for #{@model.title}'
    .fail (err)-> _.log err, 'fetchAuthorsBooks err'