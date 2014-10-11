module.exports = class AuthorLi extends Backbone.Marionette.CompositeView
  template: require 'views/entities/templates/author_li'
  tagName: "li"
  className: "author"

  childViewContainer: '.authorsBooks'
  childView: require 'views/entities/book_li'

  initialize: ->
    @collection = new Backbone.Collection

  events:
    'click a#displayBooks': 'displayBooks'

  displayBooks: ->
    @fetchBooks()
    @$el.find('#displayBooks').toggle()

  fetchBooks: ->
    @model.fetchAuthorsBooks()
    .then (models)=>
      if models?
        models.forEach (model)=> @collection.add(model)
      else 'no book found for #{@model.title}'
    .fail (err)-> _.log err, 'fetchAuthorsBooks err'