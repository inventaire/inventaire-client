forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
mergeEntities = require './lib/merge_entities'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.LayoutView.extend
  template: require './templates/merge_suggestion'
  className: -> "merge-suggestion #{@cid}"
  behaviors:
    Loading: {}
    PreventDefault: {}

  regions:
    series: '.seriesList'
    works: '.worksList'

  initialize: ->
    toEntityUri = @options.toEntity.get('uri')
    @taskModel = @model.tasks?[toEntityUri]

  serializeData: ->
    attrs = @model.toJSON()
    attrs.task = @taskModel?.toJSON()
    attrs.claimsPartial = claimsPartials[@model.type]
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
    @[name].show new SubentitiesList { collection }

  showTask: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:task', @taskModel.id

  merge: ->
    startLoading.call @, ".#{@cid} .loading"
    { toEntity } = @options
    fromUri = @model.get 'uri'
    toUri = toEntity.get 'uri'

    mergeEntities fromUri, toUri
    # Simply hidding it instead of removing it from the collection so that other
    # suggestions don't jump places, potentially leading to undesired merges
    .then => @$el.css 'visibility', 'hidden'
    .finally stopLoading.bind(@)
    .catch error_.Complete(".#{@cid} .merge", false)
    .catch forms_.catchAlert.bind(null, @)

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

SubentitiesList = Marionette.CollectionView.extend
  className: 'subentities-list'
  childView: Subentity
