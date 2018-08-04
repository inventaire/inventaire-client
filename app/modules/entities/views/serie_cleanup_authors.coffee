SerieCleanupAuthor = Marionette.ItemView.extend
  template: require './templates/serie_cleanup_author'
  className: ->
    base = 'serie-cleanup-author'
    if @options.isSuggestion then base += ' suggestion'
    return base

  attributes: ->
    'data-uri': @model.get 'uri'

  serializeData: ->
    uri: @model.get 'uri'
    isSuggestion: @options.isSuggestion

AuthorsList = Marionette.CollectionView.extend
  childView: SerieCleanupAuthor
  childViewOptions: ->
    isSuggestion: @options.name is 'authorsSuggestions'

module.exports = Marionette.LayoutView.extend
  template: require './templates/serie_cleanup_authors'
  regions:
    currentAuthorsRegion: '.currentAuthors'
    authorsSuggestionsRegion: '.authorsSuggestions'

  onShow: ->
    @showList 'currentAuthors'
    @showList 'authorsSuggestions'

  showList: (name)->
    collection = @["#{name}Collection"] or= @buildCollection(name)
    @["#{name}Region"].show new AuthorsList { collection, name }

  buildCollection: (name)->
    uris = @options["#{name}Uris"]
    authorsData = uris.map (uri)-> { uri }
    return new Backbone.Collection authorsData

  events:
    'click .suggestion': 'add'

  add: (e)->
    uri = e.currentTarget.attributes['data-uri'].value
    model = @authorsSuggestionsCollection.findWhere { uri }

    _.log model, 'model'

    @authorsSuggestionsCollection.remove model
    @currentAuthorsCollection.add model

    rollback = =>
      @authorsSuggestionsCollection.add model
      @currentAuthorsCollection.remove model

    @options.work.setPropertyValue 'wdt:P50', null, uri
    .catch rollback
