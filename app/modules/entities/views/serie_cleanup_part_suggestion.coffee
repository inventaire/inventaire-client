PartSuggestion = Marionette.ItemView.extend
  tagName: 'li'
  className: ->
    className = 'serie-cleanup-part-suggestion'
    if @model.get('labelMatch') then className += ' label-match'
    if @model.get('authorMatch') then className += ' author-match'
    return className

  template: require './templates/serie_cleanup_part_suggestion'
  initialize: ->
    @listenTo @model, 'change:image', @render.bind(@)

  onRender: ->
    @updateClassName()

  events:
    'click .add': 'add'

  add: ->
    @model.setPropertyValue 'wdt:P179', null, @options.serieUri
    @options.addToSerie @model
    @options.collection.remove @model

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: PartSuggestion
  childViewOptions: -> @options
