module.exports = Backbone.Collection.extend
  comparator: 'ordinal'
  initialize: -> @triggerUpdateEvents()

  serializeNonPlaceholderWorks: ->
    @filter isntPlaceholder
    .map (model)->
      [ oridinal, label, uri ] = model.gets 'ordinal', 'label', 'uri'
      richLabel = if oridinal? then "#{oridinal}. - #{label}" else "#{label} (#{uri})"
      if richLabel.length > 50 then richLabel = richLabel.substring(0, 50) + '...'
      return { richLabel, uri }

  getNonPlaceholdersOrdinals: ->
    @filter isntPlaceholder
    .map (model)-> model.get('ordinal')

isPlaceholder = (model)-> model.get('isPlaceholder') is true
isntPlaceholder = _.negate isPlaceholder
