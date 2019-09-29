forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
mergeEntities = require './lib/merge_entities'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/merge_suggestion'
  className: 'merge-suggestion'
  behaviors:
    AlertBox: {}
    Loading: {}
    PreventDefault: {}

  regions:
    series: '.seriesList'
    works: '.worksList'

  initialize: ->
    toEntityUri = @options.toEntity.get('uri')
    @taskModel = @model.tasks?[toEntityUri]

    @isExactMatch = haveLabelMatch @model, @options.toEntity
    { @showCheckbox } = @options

  serializeData: ->
    attrs = @model.toJSON()
    attrs.task = @taskModel?.serializeData()
    attrs.claimsPartial = claimsPartials[@model.type]
    attrs.isExactMatch = @isExactMatch
    attrs.showCheckbox = @showCheckbox
    return attrs

  events:
    'click .showTask': 'showTask'
    'click .merge': 'merge'

  onShow: ->
    if @model.get('type') isnt 'human' then return
    @model.initAuthorWorks()
    .then @ifViewIsIntact('showWorks')

  showWorks: ->
    @showSubentities 'series', @model.works.series
    @showSubentities 'works', @model.works.works

  showSubentities: (name, collection)->
    if collection.totalLength is 0 then return
    collection.fetchAll()
    .then @ifViewIsIntact('_showSubentities', name, collection)

  _showSubentities: (name, collection)->
    @$el.find(".#{name}Label").show()
    @[name].show new SubentitiesList { collection, entity: @model }

  showTask: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:task', @taskModel.id

  merge: ->
    if @_mergedAlreadyTriggered then return Promise.resolve()
    @_mergedAlreadyTriggered = true

    startLoading.call @
    { toEntity } = @options
    fromUri = @model.get 'uri'
    toUri = toEntity.get 'uri'

    mergeEntities fromUri, toUri
    # Simply hidding it instead of removing it from the collection so that other
    # suggestions don't jump places, potentially leading to undesired merges
    .then => @$el.css 'visibility', 'hidden'
    .finally stopLoading.bind(@)
    .catch error_.Complete('.merge', false)
    .catch forms_.catchAlert.bind(null, @)

  isSelected: -> @$el.find('input[type="checkbox"]').prop('checked')

haveLabelMatch = (suggestion, toEntity)->
  _.haveAMatch getNormalizedLabels(suggestion), getNormalizedLabels(toEntity)

getNormalizedLabels = (entity)-> Object.values(entity.get('labels')).map normalizeLabel
normalizeLabel = (label)-> label.toLowerCase().replace /\W+/g, ''

claimsPartials =
  author: 'entities:author_claims'
  edition: 'entities:edition_claims'
  work: 'entities:work_claims'
  serie: 'entities:work_claims'

Subentity = Marionette.ItemView.extend
  className: 'subentity'
  template: require './templates/merge_suggestion_subentity'
  attributes: ->
    title: @model.get('uri')

  serializeData: ->
    attrs = @model.toJSON()
    authorUri = @options.entity.get 'uri'
    attrs.claims['wdt:P50'] = _.without attrs.claims['wdt:P50'], authorUri
    return attrs

SubentitiesList = Marionette.CollectionView.extend
  className: 'subentities-list'
  childView: Subentity
  childViewOptions: ->
    entity: @options.entity
