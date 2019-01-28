entityDraftModel = require '../lib/entity_draft_model'
SerieCleanupWorks = require  './serie_cleanup_works'
PartsSuggestions = require  './serie_cleanup_part_suggestion'
StringPositiveInteger = /^[1-9](\d+)?$/
searchWorks = require('modules/entities/lib/sources/search_type')('works')
{ startLoading } = require 'modules/general/plugins/behaviors'
leven = require 'leven'
Works = Backbone.Collection.extend { comparator: 'ordinal' }
descendingPertinanceScore = (work)-> - work.get('pertinanceScore')
Suggestions = Backbone.Collection.extend { comparator: descendingPertinanceScore }

module.exports = Marionette.LayoutView.extend
  id: 'serieCleanup'
  className: 'hideAuthors hideEditions'
  template: require './templates/serie_cleanup'

  regions:
    conflictsRegion: '#conflicts'
    withoutOrdinalRegion: '#withoutOrdinal'
    withOrdinalRegion: '#withOrdinal'
    partsSuggestionsRegion: '#partsSuggestions'

  ui:
    authorsToggler: '.toggler-label[for="toggleAuthors"]'
    editionsToggler: '.toggler-label[for="toggleEditions"]'
    createPlaceholdersButton: '#createPlaceholders'

  behaviors:
    Toggler: {}
    ImgZoomIn: {}
    Loading: {}

  initialize: ->
    @withOrdinal = new Works
    @withoutOrdinal = new Works
    @conflicts = new Works
    @maxOrdinal = 0
    @placeholderCounter = 0
    @titleKey = "{#{_.i18n('title')}}"
    @numberKey = "{#{_.i18n('number')}}"
    @titlePattern = "#{@titleKey} - #{_.I18n('volume')} #{@numberKey}"
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
      titlePattern: @titlePattern
      placeholderCounter: @placeholderCounter
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
      # Always show so that added suggested parts can join this list
      alwaysShow: true

    @showWorkList
      name: 'withOrdinal'
      label: 'parts with ordinal'
      alwaysShow: true

    @updatePlaceholderCreationButton()

    @showPartsSuggestions()

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
    @fillGaps()

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

  fillGaps: ->
    existingOrdinals = @withOrdinal.map (model)-> model.get('ordinal')
    @partsNumber ?= 0
    lastOrdinal = _.last existingOrdinals
    end = _.max [ @partsNumber, lastOrdinal ]
    if end < 1 then return
    newPlaceholders = []
    for i in [ 1..end ]
      unless i in existingOrdinals then newPlaceholders.push @getPlaceholder(i)
    @withOrdinal.add newPlaceholders

  getPlaceholder: (index)->
    serieUri = @model.get 'uri'
    label = @getPlaceholderTitle index
    claims =
      'wdt:P179': [ serieUri ]
      'wdt:P1545': [ "#{index}" ]
    model = entityDraftModel.create { type: 'work', label, claims }
    model.set 'ordinal', index
    model.set 'isPlaceholder', true
    return model

  getPlaceholderTitle: (index)->
    serieLabel = @model.get 'label'
    @titlePattern
    .replace @titleKey, serieLabel
    .replace @numberKey, index

  events:
    'change #partsNumber': 'updatePartsNumber'
    'change #authorsToggler': 'toggleAuthors'
    'change #editionsToggler': 'toggleEditions'
    'keyup #titlePattern': 'lazyUpdateTitlePattern'
    'click #createPlaceholders': 'createPlaceholders'

  updatePartsNumber: (e)->
    { value } = e.currentTarget
    @partsNumber = parseInt value
    if @partsNumber is @maxOrdinal then return
    if @partsNumber > @maxOrdinal then @fillGaps()
    else @removePlaceholdersAbove @partsNumber
    @maxOrdinal = @partsNumber
    app.vent.trigger 'serie:cleanup:parts:change'
    @updatePlaceholderCreationButton()

  removePlaceholdersAbove: (num)->
    toRemove = @withOrdinal.filter (model)->
      model.get('isPlaceholder') and model.get('ordinal') > num
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

  lazyUpdateTitlePattern: _.lazyMethod 'updateTitlePattern', 1000
  updateTitlePattern: (e)->
    @titlePattern = e.currentTarget.value
    placeholders = @withOrdinal.filter isPlaceholder
    @withOrdinal.remove placeholders
    @fillGaps()

  updatePlaceholderCreationButton: ->
    placeholders = @withOrdinal.filter isPlaceholder
    @placeholderCounter = placeholders.length
    if @placeholderCounter > 0
      @ui.createPlaceholdersButton.find('.counter').text "(#{@placeholderCounter})"
      @ui.createPlaceholdersButton.removeClass 'hidden'
    else
      @ui.createPlaceholdersButton.addClass 'hidden'

  createPlaceholders: ->
    if @_placeholderCreationOngoing then return
    @_placeholderCreationOngoing = true

    views = _.values @withOrdinalRegion.currentView.children._views
    startLoading.call @, { selector: '#createPlaceholders', timeout: 300 }

    createSequentially = ->
      nextView = views.shift()
      unless nextView? then return
      nextView.create()
      .then createSequentially

    createSequentially()
    .then =>
      @_placeholderCreationOngoing = false
      @updatePlaceholderCreationButton()

  showPartsSuggestions: ->
    Promise.all [
      @getAuthorsWorks()
      @searchMatchWorks()
    ]
    .then _.flatten
    .then _.uniq
    .then (uris)-> app.request 'get:entities:models', { uris }
    # Confirm the type, as the search might have failed to unindex a serie that use
    # to be considered a work
    .filter isWork
    .map addPertinanceScore(@model)
    .filter (work)-> work.get('authorMatch') or work.get('labelMatch')
    .then @_showPartsSuggestions.bind(@)

  getAuthorsWorks: ->
    Promise.all @getAuthorsUris()
    .map (authorUri)-> _.preq.get app.API.entities.authorWorks(authorUri)
    .map (results)-> _.map results.works.filter(hasNoSerie), 'uri'
    .then _.flatten

  searchMatchWorks: ->
    serieLabel = @model.get 'label'
    partsUris = @model.parts.allUris
    searchWorks serieLabel, 20
    .filter (result)-> result._score > 0.5 and result.uri not in partsUris
    .map _.property('uri')

  _showPartsSuggestions: (works)->
    collection = new Suggestions works
    addToSerie = @spreadPart.bind @
    serieUri = @model.get 'uri'
    @partsSuggestionsRegion.show new PartsSuggestions({ collection, addToSerie, serieUri })

getWorksWithOrdinalList = ->
  if @withoutOrdinal.length + @conflicts.length isnt 0 then return

  @withOrdinal
  .filter (model)-> not model.get('isPlaceholder')
  .map (model)->
    [ oridinal, label, uri ] = model.gets 'ordinal', 'label', 'uri'
    return { richLabel: "#{oridinal}. - #{label}", uri }

getPlaceholdersOrdinals = ->
  @withOrdinal
  .filter isPlaceholder
  .map (model)-> model.get('ordinal')

isPlaceholder = (model)-> model.get('isPlaceholder') is true

getAuthors = (model)-> model.getExtendedAuthorsUris()

hasNoSerie = (work)-> not work.serie?
isWork = (work)-> work.get('type') is 'work'

addPertinanceScore = (serie)-> (work)->
  authorsScore = getAuthorsIntersectionLength(serie, work) * 10
  smallestLabelDistance = getSmallestLabelDistance serie, work
  pertinanceScore = authorsScore - smallestLabelDistance
  authorMatch = authorsScore > 0
  labelMatch = smallestLabelDistance < 5
  work.set { pertinanceScore, labelMatch, authorMatch }
  return work

getAuthorsIntersectionLength = (serie, work)->
  workAuthorsUris = work.getExtendedAuthorsUris()
  serieAuthorsUris = serie.getExtendedAuthorsUris()
  intersection = _.intersection workAuthorsUris, serieAuthorsUris
  return intersection.length

getSmallestLabelDistance = (serie, work)->
  serieLabels = _.values serie.get('labels')
  workLabels = _.values work.get('labels')
  labelsScores = serieLabels.map (serieLabel)-> workLabels.map distance(serieLabel)
  return _.min _.flatten(labelsScores)

distance = (a)-> (b)-> leven a, b
