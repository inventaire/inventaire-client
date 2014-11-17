module.exports = class AuthorLi extends Backbone.Marionette.CompositeView
  template: require './templates/author_li'
  tagName: "li"
  className: "authorLi"
  behaviors:
    Loading: {}

  childViewContainer: '.authorsBooks'
  childView: require './book_li'
  # doesnt show up
  emptyView: require 'modules/inventory/views/no_item'

  initialize: (options)->
    @listenTo @model, 'add:pictures', @render
    @collection = new Backbone.Collection
    @listenTo @collection, 'add', @render
    # if options.displayBooks then @onShow = @displayBooks

  events:
    'click a#displayBooks': 'displayBooks'

  displayBooks: ->
    @fetchBooks()
    @$el.trigger 'loading'

  onRender: ->
    if @collection?.length > 0
      @$el.find('#displayBooks').hide()
      @$el.trigger 'stopLoading'
    else if @options.displayBooks
      @displayBooks()

  fetchBooks: ->
    if @model.fetchAuthorsBooks?
      @model.fetchAuthorsBooks()
      .then (models)=>
        @$el.trigger 'stopLoading'
        if models?
          models.forEach (model)=>
            @collection.add(model)
        else 'no book found for #{@model.title}'
        @$el.find('#displayBooks').hide()
      .fail (err)-> _.log err, 'fetchAuthorsBooks err'
    else
      _.log [@model.get('title'), @model,@], 'couldnt fetchAuthorsBooks'