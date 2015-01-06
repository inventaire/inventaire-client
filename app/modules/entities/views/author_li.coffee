module.exports = class AuthorLi extends Backbone.Marionette.CompositeView
  template: require './templates/author_li'
  tagName: "li"
  className: "authorLi"
  behaviors:
    Loading: {}
    WikiBar: {}

  childViewContainer: '.authorsBooks'
  childView: require './book_li'
  # doesnt show up
  emptyView: require 'modules/inventory/views/no_item'

  initialize: (options)->
    @listenTo @model, 'add:pictures', @render
    @collection = new Backbone.Collection
    _.inspect @


  serializeData: ->
    attrs = @model.toJSON()
    attrs.wikipediaPreview = @options.wikipediaPreview or true
    return attrs

  events:
    'click a#displayBooks': 'displayBooks'
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'

  displayBooks: ->
    @$el.trigger 'loading'
    @fetchBooks()

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
        if models?
          models.forEach (model)=>
            @collection.add(model)
        else 'no book found for #{@model.title}'
        @$el.find('#displayBooks').hide()
      .fail (err)-> _.log err, 'fetchAuthorsBooks err'
      .always ()=> @$el.trigger 'stopLoading'
    else
      _.log [@model.get('title'), @model,@], 'couldnt fetchAuthorsBooks'

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @