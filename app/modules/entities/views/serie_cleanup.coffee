entityDraftModel = require '../lib/entity_draft_model'
serieCleanupWorks = require  './serie_cleanup_works'
StringPositiveInteger = /^[1-9](\d+)?$/
Works = Backbone.Collection.extend { comparator: 'ordinal' }

module.exports = Marionette.LayoutView.extend
  id: 'serieCleanup'
  className: 'hideEditions'
  template: require './templates/serie_cleanup'

  regions:
    conflictsRegion: '#conflicts'
    withoutOrdinalRegion: '#withoutOrdinal'
    withOrdinalRegion: '#withOrdinal'

  ui:
    editionsToggler: '.toggler-label'

  behaviors:
    Toggler: {}
    ImgZoomIn: {}

  initialize: ->
    @withOrdinal = new Works
    @withoutOrdinal = new Works
    @conflicts = new Works
    @maxOrdinal = 0
    @spreadParts()
    @initEventListeners()
    @getWorksWithOrdinalList = getWorksWithOrdinalList.bind @

  serializeData: ->
    partsLength = @withOrdinal.length

    return {
      serie: @model.toJSON()
      partsNumberPickerRange: [ @maxOrdinal..partsLength + 10 ]
      editionsToggler:
        id: 'editionsToggler'
        checked: @showEditions
        label: 'show editions'
    }

  onRender: ->
    placeholdersOrdinals = @getPlaceholdersOrdinals()

    @showWorkList
      name: 'conflicts'
      label: 'parts with ordinal conflicts'
      possibleOrdinals: placeholdersOrdinals

    @showWorkList
      name: 'withoutOrdinal'
      label: 'parts without ordinal'
      possibleOrdinals: placeholdersOrdinals

    @showWorkList
      name: 'withOrdinal'
      label: 'parts with ordinal'
      alwaysShow: true

  showWorkList: (options)->
    { name, label, alwaysShow, possibleOrdinals } = options
    if not alwaysShow and @[name].length is 0 then return
    collection = @[name]
    options = { name, label, collection, possibleOrdinals, @getWorksWithOrdinalList }
    @["#{name}Region"].show new serieCleanupWorks(options)

  spreadParts: ->
    @model.parts.forEach @spreadPart.bind(@)
    @fillGaps 1, @maxOrdinal

  initEventListeners: ->
    @listenTo @withoutOrdinal, 'change:claims.wdt:P1545', @moveModelOnOrdinalChange.bind(@)

  moveModelOnOrdinalChange: (model, value)->
    unless _.isNonEmptyArray value then return
    [ ordinal ] = value
    unless StringPositiveInteger.test ordinal then return

    ordinalInt = parseInt ordinal
    model.set 'ordinal', ordinalInt

    @removePlaceholder ordinalInt

    @withoutOrdinal.remove model
    @withOrdinal.add model

    # Re-render to update editions works pickers
    @render()
    if @withoutOrdinal.length is 0 and not @showEditions and not@editionsTogglerChanged
      @ui.editionsToggler.addClass 'glowing'

  removePlaceholder: (ordinalInt)->
    existingModel = @withOrdinal.findWhere { ordinal: ordinalInt }
    if existingModel? and existingModel.get('isPlaceholder')
      @withOrdinal.remove existingModel

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
      'wdt:P179': [ serieUri ]
      'wdt:P1545': [ "#{index}" ]
    model = entityDraftModel.create { type: 'work', label, claims }
    model.set 'ordinal', index
    model.set 'isPlaceholder', true
    return model

  getPlaceholdersOrdinals: ->
    @withOrdinal
    .filter (model)-> model.get('isPlaceholder')
    .map  (model)-> model.get('ordinal')

  events:
    'change #partsNumber': 'updatePartsNumber'
    'change .toggler-input': 'toggleEditions'

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
      if model.get('isPlaceholder') and model.get('ordinal') > num
        toRemove.push model
    @withOrdinal.remove toRemove

  toggleEditions: (e)->
    { checked } = e.currentTarget
    if checked
      @$el.removeClass 'hideEditions'
      @showEditions = true
    else
      @$el.addClass 'hideEditions'
      @showEditions = false
    @editionsTogglerChanged = true
    @ui.editionsToggler.removeClass 'glowing'

getWorksWithOrdinalList = ->
  if @withoutOrdinal.length + @conflicts.length isnt 0 then return

  @withOrdinal
  .filter (model)-> not model.get('isPlaceholder')
  .map (model)->
    [ oridinal, label, uri ] = model.gets 'ordinal', 'label', 'uri'
    return { richLabel: "#{oridinal}. - #{label}", uri }
