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
    @$el.once 'inview', @fetchBooks.bind(@)


  serializeData: ->
    attrs = @model.toJSON()
    attrs.wikipediaPreview = @options.wikipediaPreview or true
    return attrs

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'

  fetchBooks: ->
    _.log @model, "author:#{@model.get('label')}:fetching my books!"
    if @model.fetchAuthorsBooks?
      @$el.trigger 'loading'
      @model.fetchAuthorsBooks()
      .then (models)=>
        if models?
          models.forEach (model)=>
            @collection.add(model)
        else 'no book found for #{@model.title}'
      .fail (err)-> _.log err, 'fetchAuthorsBooks err'
      .always ()=> @$el.trigger 'stopLoading'
    else
      _.log [@model.get('title'), @model,@], 'couldnt fetchAuthorsBooks'

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @