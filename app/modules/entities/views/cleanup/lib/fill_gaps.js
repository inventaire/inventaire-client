entityDraftModel = require 'modules/entities/lib/entity_draft_model'

module.exports = ->
  existingOrdinals = @worksWithOrdinal.map (model)-> model.get('ordinal')
  @partsNumber ?= 0
  lastOrdinal = _.last existingOrdinals
  end = _.max [ @partsNumber, lastOrdinal ]
  if end < 1 then return
  newPlaceholders = []
  for i in [ 1..end ]
    unless i in existingOrdinals then newPlaceholders.push getPlaceholder.call(@, i)
  @worksWithOrdinal.add newPlaceholders

getPlaceholder = (index)->
  serieUri = @model.get 'uri'
  label = getPlaceholderTitle.call @, index
  claims =
    'wdt:P179': [ serieUri ]
    'wdt:P1545': [ "#{index}" ]
  model = entityDraftModel.create { type: 'work', label, claims }
  model.set 'ordinal', index
  model.set 'isPlaceholder', true
  return model

getPlaceholderTitle = (index)->
  serieLabel = @model.get 'label'
  @titlePattern
  .replace @titleKey, serieLabel
  .replace @numberKey, index
