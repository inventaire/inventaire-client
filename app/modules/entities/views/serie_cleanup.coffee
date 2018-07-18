entityDraftModel = require '../lib/entity_draft_model'
serieCleanupWorks = require  './serie_cleanup_works'
StringPositiveInteger = /^[1-9](\d+)?$/

module.exports = Marionette.LayoutView.extend
  id: 'serieCleanup'
  template: require './templates/serie_cleanup'

  regions:
    conflictsRegion: '#conflicts'
    withoutOrdinalRegion: '#withoutOrdinal'
    withOrdinalRegion: '#withOrdinal'

  initialize: ->
    @lazyRender = _.LazyRender @
    resetData.call @

    # @model.initSerieParts { refresh: true, fetchAll: true }
    @model.initSerieParts { refresh: false, fetchAll: true }
    .then spreadParts.bind(@)
    .then @lazyRender

  serializeData: ->
    partsLength = @withOrdinal.length

    return {
      serie: @model.toJSON()
      partsNumberPickerRange: [ @maxOrdinal..partsLength + 10 ]
      partsLengthRange: [ 1..partsLength ]
    }

  onRender: ->
    @showWorkList 'conflicts', 'parts with ordinal conflicts'
    @showWorkList 'withoutOrdinal', 'parts without ordinal'
    @showWorkList 'withOrdinal', 'parts with ordinal'

  showWorkList: (name, label, alwaysShow)->
    if not alwaysShow and @[name].length is 0 then return
    collection = new Backbone.Collection @[name]
    @["#{name}Region"].show new serieCleanupWorks { name, label, collection }

resetData = ->
  @withOrdinal = []
  @withoutOrdinal = []
  @conflicts = []
  @maxOrdinal = 0

spreadParts = ->
  resetData.call @
  @model.parts.forEach spreadPart.bind(@)
  fillGaps @model, @withOrdinal

spreadPart = (part)->
  ordinal = part.get 'claims.wdt:P1545.0'

  unless StringPositiveInteger.test ordinal
    @withoutOrdinal.push part
    return

  ordinalInt = parseInt ordinal
  if ordinalInt > @maxOrdinal then @maxOrdinal = ordinalInt

  currentOrdinalValue = @withOrdinal[ordinalInt]
  if currentOrdinalValue? then @conflicts.push part
  else @withOrdinal[ordinalInt] = part

fillGaps = (serie, withOrdinal)->
  for part, index in withOrdinal
    fillGap serie, withOrdinal, index

fillGap = (serie, withOrdinal, index)->
  if index is 0 then return
  withOrdinal[index] ?= getPlaceholder serie, index
  withOrdinal[index].set 'ordinal', index

getPlaceholder = (serie, index)->
  serieUri = serie.get 'uri'
  serieLabel = serie.get 'label'
  label = "#{serieLabel} - #{index}"
  claims =
    'wdt:179': [ serieUri ]
    'wdt:P1545': [ "#{index}" ]
  model = entityDraftModel.create { type: 'work', label, claims }
  model.set 'placeholder', true
  return model
