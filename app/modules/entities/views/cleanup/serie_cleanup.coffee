SerieCleanupWorks = require  './serie_cleanup_works'
SerieCleanupEditions = require './serie_cleanup_editions'
PartsSuggestions = require  './serie_cleanup_part_suggestion'
{ getReverseClaims } = require 'modules/entities/lib/entities'
CleanupWorks = require './collections/cleanup_works'
getPartsSuggestions = require './lib/get_parts_suggestions'
fillGaps = require './lib/fill_gaps'
spreadPart = require './lib/spread_part'
moveModelOnOrdinalChange = require './lib/move_model_on_ordinal_change'
{ createPlaceholders, removePlaceholder, removePlaceholdersAbove } = require './lib/placeholders'

module.exports = Marionette.LayoutView.extend
  id: 'serieCleanup'
  template: require './templates/serie_cleanup'

  regions:
    worksInConflictsRegion: '#worksInConflicts'
    isolatedEditionsRegion: '#isolatedEditions'
    worksWithoutOrdinalRegion: '#worksWithoutOrdinal'
    worksWithOrdinalRegion: '#worksWithOrdinal'
    partsSuggestionsRegion: '#partsSuggestions'

  ui:
    authorsToggler: '.toggler-label[for="toggleAuthors"]'
    editionsToggler: '.toggler-label[for="toggleEditions"]'
    sizeToggler: '.toggler-label[for="sizeToggler"]'
    createPlaceholdersButton: '#createPlaceholders'
    isolatedEditionsWrapper: '#isolatedEditionsWrapper'

  behaviors:
    Toggler: {}
    ImgZoomIn: {}
    Loading: {}

  initialize: ->
    @worksWithOrdinal = new CleanupWorks
    @worksWithoutOrdinal = new CleanupWorks
    @worksInConflicts = new CleanupWorks
    @maxOrdinal = 0
    @placeholderCounter = 0
    @titleKey = "{#{_.i18n('title')}}"
    @numberKey = "{#{_.i18n('number')}}"
    @titlePattern = "#{@titleKey} - #{_.I18n('volume')} #{@numberKey}"
    @allAuthorsUris = @model.getAllAuthorsUris()
    @model.parts.forEach spreadPart.bind(@)
    fillGaps.call @
    @initEventListeners()

  serializeData: ->
    partsLength = @worksWithOrdinal.length

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
      sizeToggler:
        id: 'sizeToggler'
        checked: @displayLarge
        label: 'large mode'
      titlePattern: @titlePattern
      placeholderCounter: @placeholderCounter
    }

  onRender: ->
    @showWorkList
      name: 'worksInConflicts'
      label: 'parts with ordinal conflicts'
      showPossibleOrdinals: true

    @showWorkList
      name: 'worksWithoutOrdinal'
      label: 'parts without ordinal'
      showPossibleOrdinals: true
      # Always show so that added suggested parts can join this list
      alwaysShow: true

    @showWorkList
      name: 'worksWithOrdinal'
      label: 'parts with ordinal'
      alwaysShow: true

    @showIsolatedEditions()

    @updatePlaceholderCreationButton()

    @showPartsSuggestions()

  showWorkList: (options)->
    { name, label, alwaysShow, showPossibleOrdinals } = options
    if not alwaysShow and @[name].length is 0 then return
    @["#{name}Region"].show new SerieCleanupWorks {
      name,
      label,
      collection: @[name],
      showPossibleOrdinals,
      @worksWithOrdinal,
      @worksWithoutOrdinal,
      @allAuthorsUris
    }

  initEventListeners: ->
    @listenTo @worksWithoutOrdinal, 'change:claims.wdt:P1545', moveModelOnOrdinalChange.bind(@)
    @listenTo @worksWithOrdinal, 'update', @updatePlaceholderCreationButton.bind(@)

  events:
    'change #partsNumber': 'updatePartsNumber'
    'change #authorsToggler': 'toggleAuthors'
    'change #editionsToggler': 'toggleEditions'
    'change #sizeToggler': 'toggleSize'
    'keyup #titlePattern': 'lazyUpdateTitlePattern'
    'click #createPlaceholders': 'createPlaceholders'

  updatePartsNumber: (e)->
    { value } = e.currentTarget
    @partsNumber = parseInt value
    if @partsNumber is @maxOrdinal then return
    if @partsNumber > @maxOrdinal then fillGaps.call @
    else @removePlaceholdersAbove @partsNumber
    @maxOrdinal = @partsNumber
    app.vent.trigger 'serie:cleanup:parts:change'

  createPlaceholders: createPlaceholders
  removePlaceholder: removePlaceholder
  removePlaceholdersAbove: removePlaceholdersAbove

  toggleAuthors: (e)->
    @toggle 'authors', 'showAuthors', e

  toggleEditions: (e)->
    @toggle 'editions', 'showEditions', e
    @ui.editionsToggler.removeClass 'glowing'

  toggleSize: (e)->
    @toggle 'size', 'displayLarge', e

  toggle: (name, actionName, e)->
    { checked } = e.currentTarget
    if checked
      @$el.addClass actionName
      @[actionName] = true
    else
      @$el.removeClass actionName
      @[actionName] = false
    @["#{name}TogglerChanged"] = true

  lazyUpdateTitlePattern: _.lazyMethod 'updateTitlePattern', 1000
  updateTitlePattern: (e)->
    @titlePattern = e.currentTarget.value
    placeholders = @worksWithOrdinal.filter isPlaceholder
    @worksWithOrdinal.remove placeholders
    fillGaps.call @

  updatePlaceholderCreationButton: ->
    placeholders = @worksWithOrdinal.filter isPlaceholder
    @placeholderCounter = placeholders.length
    if @placeholderCounter > 0
      @ui.createPlaceholdersButton.find('.counter').text "(#{@placeholderCounter})"
      @ui.createPlaceholdersButton.removeClass 'hidden'
    else
      @ui.createPlaceholdersButton.addClass 'hidden'

  showPartsSuggestions: ->
    serie = @model
    addToSerie = spreadPart.bind @
    getPartsSuggestions serie
    .then (collection)=>
      @partsSuggestionsRegion.show new PartsSuggestions { collection, addToSerie, serie }

  showIsolatedEditions: ->
    getIsolatedEditions @model.get('uri')
    .then (editions)=>
      if editions.length is 0 then return
      @ui.isolatedEditionsWrapper.removeClass 'hidden'
      collection = new Backbone.Collection editions
      @isolatedEditionsRegion.show new SerieCleanupEditions {
        collection,
        @worksWithOrdinal,
        @worksWithoutOrdinal
      }
      @listenTo collection, 'remove', @hideIsolatedEditionsWhenEmpty.bind(@)

  hideIsolatedEditionsWhenEmpty: (removedEdition, collection)->
    if collection.length is 0 then @ui.isolatedEditionsWrapper.addClass 'hidden'

getIsolatedEditions = (serieUri)->
  getReverseClaims 'wdt:P629', serieUri, true
  .then (uris)-> app.request 'get:entities:models', { uris }

isPlaceholder = (model)-> model.get('isPlaceholder') is true
