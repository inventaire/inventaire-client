module.exports = Backbone.Collection.extend
  comparator: 'ordinal'
  initialize: -> @triggerUpdateEvents()

  serializeNonPlaceholderWorks: ->
    @filter (model)-> not model.get('isPlaceholder')
    .map (model)->
      [ oridinal, label, uri ] = model.gets 'ordinal', 'label', 'uri'
      return { richLabel: "#{oridinal}. - #{label}", uri }

  getPlaceholdersOrdinals: ->
    @filter isPlaceholder
    .map (model)-> model.get('ordinal')

isPlaceholder = (model)-> model.get('isPlaceholder') is true
