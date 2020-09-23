WorkPicker = require './work_picker'
mergeEntities = require 'modules/entities/views/editor/lib/merge_entities'

PartSuggestion = WorkPicker.extend
  tagName: 'li'
  className: ->
    className = 'serie-cleanup-part-suggestion'
    if @model.get('labelMatch') then className += ' label-match'
    if @model.get('authorMatch') then className += ' author-match'
    return className

  template: require './templates/serie_cleanup_part_suggestion'
  initialize: ->
    @isWikidataEntity = @workPickerDisabled = @model.get 'isWikidataEntity'
    WorkPicker::initialize.call @
    @listenTo @model, 'change:image', @render.bind(@)

  onRender: ->
    @updateClassName()
    WorkPicker::onRender.call @

  serializeData: ->
    attrs = @model.toJSON()
    if @isWikidataEntity
      attrs.workPickerDisabled = true
      unless @options.serie.get('isWikidataEntity') then attrs.serieNeedsToBeMovedToWikidata = true
    else
      if @_showWorkPicker then attrs.worksList = @getWorksList()
      attrs.workPicker =
        buttonIcon: 'compress'
        buttonLabel: 'merge'
        validateLabel: 'merge'
    return attrs

  afterMerge: (work)->
    @model.collection.remove @model
    work.editions.add @model.editions.models

  events: _.extend {}, WorkPicker::events,
    'click a.add': 'add'

  add: ->
    @model.setPropertyValue 'wdt:P179', null, @options.serie.get('uri')
    @options.addToSerie @model
    @options.collection.remove @model

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: PartSuggestion
  childViewOptions: -> @options
