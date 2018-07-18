entityDraftModel = require '../lib/entity_draft_model'
serieCleanupWorks = require  './serie_cleanup_works'
StringPositiveInteger = /^[1-9](\d+)?$/
Works = Backbone.Collection.extend { comparator: 'ordinal' }

module.exports = Marionette.LayoutView.extend
  id: 'serieCleanup'
  template: require './templates/serie_cleanup'

  regions:
    conflictsRegion: '#conflicts'
    withoutOrdinalRegion: '#withoutOrdinal'
    withOrdinalRegion: '#withOrdinal'

  initialize: ->
    @withOrdinal = new Works
    @withoutOrdinal = new Works
    @conflicts = new Works
    @maxOrdinal = 0
    @spreadParts()

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
    @showWorkList 'withOrdinal', 'parts with ordinal', true

  showWorkList: (name, label, alwaysShow)->
    if not alwaysShow and @[name].length is 0 then return
    collection = @[name]
    @["#{name}Region"].show new serieCleanupWorks { name, label, collection }

  spreadParts: ->
    @model.parts.forEach @spreadPart.bind(@)
    @maxOrdinalFromExistingParts = @maxOrdinal
    @fillGaps 1, @maxOrdinal

  spreadPart: (part)->
    ordinal = part.get 'claims.wdt:P1545.0'

    unless StringPositiveInteger.test ordinal
      @withoutOrdinal.add part
      return

    ordinalInt = parseInt ordinal
    if ordinalInt > @maxOrdinal then @maxOrdinal = ordinalInt

    part.set 'ordinal', ordinalInt

    currentOrdinalValue = @withOrdinal[ordinalInt]
    if currentOrdinalValue? then @conflicts.add part
    else @withOrdinal.add part

  fillGaps: (start, end)->
    if start >= end then return
    existingOrdinals = @withOrdinal.map (model)-> model.get('ordinal')
    for i in [ start..end ]
      unless i in existingOrdinals then @withOrdinal.add @getPlaceholder(i)
    return

  getPlaceholder: (index)->
    serieUri = @model.get 'uri'
    serieLabel = @model.get 'label'
    label = "#{serieLabel} - #{index}"
    claims =
      'wdt:179': [ serieUri ]
      'wdt:P1545': [ "#{index}" ]
    model = entityDraftModel.create { type: 'work', label, claims }
    model.set 'ordinal', index
    model.set 'placeholder', true
    return model

  events:
    'change #partsNumber': 'updatePartsNumber'

  updatePartsNumber: (e)->
    { value } = e.currentTarget
    num = parseInt value
    if num is @maxOrdinal then return
    if num > @maxOrdinal
      @fillGaps @maxOrdinal, num
      @maxOrdinal = num
    else
      @removePlaceholdersAbove num

  removePlaceholdersAbove: (num)->
    toRemove = []
    @withOrdinal.forEach (model)->
      if model.get('placeholder') and model.get('ordinal') > num
        toRemove.push model
    @withOrdinal.remove toRemove
