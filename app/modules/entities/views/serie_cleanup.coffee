entityDraftModel = require '../lib/entity_draft_model'
SerieCleanupWorks = require  './serie_cleanup_works'
StringPositiveInteger = /^[1-9](\d+)?$/
Works = Backbone.Collection.extend { comparator: 'ordinal' }

module.exports = Marionette.LayoutView.extend
  id: 'serieCleanup'
  className: 'hideAuthors hideEditions'
  template: require './templates/serie_cleanup'

  regions:
    conflictsRegion: '#conflicts'
    withoutOrdinalRegion: '#withoutOrdinal'
    withOrdinalRegion: '#withOrdinal'

  ui:
    authorsToggler: '.toggler-label[for="toggleAuthors"]'
    editionsToggler: '.toggler-label[for="toggleEditions"]'

  behaviors:
    Toggler: {}
    ImgZoomIn: {}

  initialize: ->
    @withOrdinal = new Works
    @withoutOrdinal = new Works
    @conflicts = new Works
    @maxOrdinal = 0
    @allAuthorsUris = @getAuthorsUris()
    @spreadParts()
    @initEventListeners()
    @getWorksWithOrdinalList = getWorksWithOrdinalList.bind @
    @getPlaceholdersOrdinals = getPlaceholdersOrdinals.bind @

  serializeData: ->
    partsLength = @withOrdinal.length

    return {
      serie: @model.toJSON()
      partsNumberPickerRange: [ @maxOrdinal..partsLength + 50 ]
      authorsToggler:
        id: 'authorsToggler'
        checked: @showAuthors
        label: 'show authors'
      editionsToggler:
        id: 'editionsToggler'
        checked: @showEditions
        label: 'show editions'
    }

  onRender: ->
    @showWorkList
      name: 'conflicts'
      label: 'parts with ordinal conflicts'
      showPossibleOrdinals: true

    @showWorkList
      name: 'withoutOrdinal'
      label: 'parts without ordinal'
      showPossibleOrdinals: true

    @showWorkList
      name: 'withOrdinal'
      label: 'parts with ordinal'
      alwaysShow: true

  showWorkList: (options)->
    { name, label, alwaysShow, showPossibleOrdinals } = options
    if not alwaysShow and @[name].length is 0 then return
    collection = @[name]
    options = {
      name,
      label,
      collection,
      @getWorksWithOrdinalList,
      showPossibleOrdinals,
      @getPlaceholdersOrdinals,
      worksWithOrdinal: @withOrdinal,
      @allAuthorsUris
    }
    @["#{name}Region"].show new SerieCleanupWorks(options)

  getAuthorsUris: ->
    allAuthorsUris = getAuthors(@model).concat @model.parts.map(getAuthors)...
    return _.uniq _.compact(allAuthorsUris)

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

    if @withoutOrdinal.length is 0
      unless @showEditions or @editionsTogglerChanged
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

  events:
    'change #partsNumber': 'updatePartsNumber'
    'change #authorsToggler': 'toggleAuthors'
    'change #editionsToggler': 'toggleEditions'

  updatePartsNumber: (e)->
    { value } = e.currentTarget
    num = parseInt value
    if num is @maxOrdinal then return
    if num > @maxOrdinal then @fillGaps @maxOrdinal, num
    else @removePlaceholdersAbove num
    @maxOrdinal = num
    app.vent.trigger 'serie:cleanup:parts:change'

  removePlaceholdersAbove: (num)->
    toRemove = []
    @withOrdinal.forEach (model)->
      if model.get('isPlaceholder') and model.get('ordinal') > num
        toRemove.push model
    @withOrdinal.remove toRemove

  toggleAuthors: (e)->
    @toggle 'authors', e

  toggleEditions: (e)->
    @toggle 'editions', e
    @ui.editionsToggler.removeClass 'glowing'

  toggle: (name, e)->
    { checked } = e.currentTarget
    capitalizedName = _.capitalise name
    className = "hide#{capitalizedName}"
    if checked
      @$el.removeClass className
      @["show#{capitalizedName}"] = true
    else
      @$el.addClass className
      @["show#{capitalizedName}"] = false
    @["#{name}TogglerChanged"] = true

getWorksWithOrdinalList = ->
  if @withoutOrdinal.length + @conflicts.length isnt 0 then return

  @withOrdinal
  .filter (model)-> not model.get('isPlaceholder')
  .map (model)->
    [ oridinal, label, uri ] = model.gets 'ordinal', 'label', 'uri'
    return { richLabel: "#{oridinal}. - #{label}", uri }

getPlaceholdersOrdinals = ->
  @withOrdinal
  .filter (model)-> model.get('isPlaceholder')
  .map  (model)-> model.get('ordinal')

getAuthors = (model)-> model.get('claims.wdt:P50') or []
