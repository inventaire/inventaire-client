PartSuggestion = Marionette.ItemView.extend
  tagName: 'li'
  className: 'serie-cleanup-part-suggestion'
  template: require './templates/serie_cleanup_part_suggestion'
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
