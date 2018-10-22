# TODO:
# - hint to input ISBNs directly, maybe in the alternatives sections
# - add 'help': indexed wiki.inventaire.io entries to give results
#   to searches such as 'FAQ' or 'help creating group'
# - add 'subjects': search Wikidata for entities that are used
#   as 'main subject' (wdt:P921)
# - add 'place': search Wikidata for entities with coordinates (wdt:P625)
#   and display a layout with users & groups nearby, as well as books with
#   narrative location (wdt:P840), or authors born (wdt:P19)
#   or dead (wdt:P20) nearby

Results = Backbone.Collection.extend { model: require('../models/result') }
wikidataSearch = require 'modules/entities/lib/sources/wikidata_search'
findUri = require '../lib/find_uri'
spinner = _.icon 'circle-o-notch', 'fa-spin'
error_ = require 'lib/error'

module.exports = Marionette.CompositeView.extend
  id: 'live-search'
  template: require './templates/live_search'
  childViewContainer: 'ul.results'
  childView: require './result'
  emptyView: require './no_result'

  initialize: ->
    @collection = new Results
    @lazySearch = _.debounce @search.bind(@), 200

  ui:
    all: '#filter-all'
    filters: '.searchFilter'
    results: 'ul.results'
    alternatives: '.alternatives'
    shortcuts: '.shortcuts'

  events:
    'click .searchFilter': 'updateFilters'
    'click .deepSearch': 'showDeepSearch'
    'click .createEntity': 'showEntityCreate'

  onSpecialKey: (key)->
    switch key
      when 'up' then @highlightPrevious()
      when 'down' then @highlightNext()
      when 'enter' then @showCurrentlyHighlightedResult()
      when 'pageup' then @selectPrevFilter()
      when 'pagedown' then @selectNextFilter()
      else return

  updateFilters: (e)-> @selectFromTarget $(e.currentTarget)

  selectPrevFilter: -> @selectByPosition 'prev', 'last'
  selectNextFilter: -> @selectByPosition 'next', 'first'
  selectByPosition: (relation, fallback)->
    $target = @$el.find('.selected')[relation]()
    if $target.length is 0 then $target = @$el.find('.filters a')[fallback]()
    @selectFromTarget $target

  selectFromTarget: ($target)->
    { id } = $target[0]
    isSelected = $target.hasClass 'selected'
    type = getTypeFromId id
    if type is @_lastType then return
    if isSelected
      $target.removeClass 'selected'
      @ui.all.addClass 'selected'
      @filter = null
    else
      @ui.filters.removeClass 'selected'
      $target.addClass 'selected'
      if type is 'all' then @filter = null
      else @filter = (child)-> child.get('typeAlias') is type

    # Refresh the search with the new filters
    @search @_lastSearch
    @_lastType = type

    @updateAlternatives type

  updateAlternatives: (type)->
    if type in filtersWithAlternatives then @showAlternatives()
    else @hideAlternatives()

  search: (search)->
    search = search?.trim()

    unless _.isNonEmptyString search
      @hideAlternatives()
      @resetResults()
      return

    @_lastSearch = search

    uri = findUri search
    if uri? then return @getResultFromUri uri

    types = @getTypes()

    # Subjects aren't indexed in the server ElasticSearch
    # as it's not a subset of Wikidata anymore: pretty much anything
    # on Wikidata can be considered a subject
    if types is 'subjects'
      wikidataSearch search, false
      .map formatSubject
      .then @resetResults.bind(@)
    else
      _.preq.get app.API.search(types, search, app.user.lang)
      .get 'results'
      .then @resetResults.bind(@)

    @_waitingForAlternatives = true
    @setTimeout @showAlternatives.bind(@, search), 2000

  showAlternatives: (search)->
    unless _.isNonEmptyString search then return
    unless search is @_lastSearch then return
    unless @_waitingForAlternatives then return

    @ui.alternatives.addClass 'shown'
    @_waitingForAlternatives = false

  hideAlternatives: ->
    @_waitingForAlternatives = false
    @ui.alternatives.removeClass 'shown'

  showShortcuts: -> @ui.shortcuts.addClass 'shown'

  getResultFromUri: (uri)->
    _.log uri, 'uri found'
    @showLoadingSpinner()

    app.request 'get:entity:model', uri
    .catch (err)->
      if err.message is 'entity_not_found' then return
      else throw err
    .finally @stopLoadingSpinner.bind(@)
    .then (entity)=> @resetResults [ formatEntity(entity) ]

  showLoadingSpinner: -> @ui.results.addClass('loading').html spinner
  stopLoadingSpinner: -> @ui.results.removeClass('loading').html ''

  getTypes: ->
    name = getTypeFromId @$el.find('.selected')[0].id
    return typesMap[name]

  resetResults: (results)->
    @resetHighlightIndex()
    @collection.reset results
    if results? and results.length is 0
      @$el.addClass 'results-0'
    else
      @$el.removeClass 'results-0'
      @setTimeout @showShortcuts.bind(@), 1000

  highlightNext: -> @highlightIndexChange 1
  highlightPrevious: -> @highlightIndexChange -1
  highlightIndexChange: (incrementor)->
    @_currentHighlightIndex ?= -1
    newIndex = @_currentHighlightIndex + incrementor
    previousView = @children.findByIndex @_currentHighlightIndex
    view = @children.findByIndex newIndex
    if view?
      previousView?.unhighlight()
      view.highlight()
      @_currentHighlightIndex = newIndex

      _.innerScrollTop @ui.results, view?.$el

  showCurrentlyHighlightedResult: ->
    hilightedView = @children.findByIndex @_currentHighlightIndex
    if hilightedView then hilightedView.showResult()

  resetHighlightIndex: ->
    @$el.find('.highlight').removeClass 'highlight'
    @_currentHighlightIndex = -1

  showDeepSearch: -> @triggerMethod 'show:deep:search'

  showEntityCreate: ->
    @triggerMethod 'hide:live:search'
    app.execute 'show:entity:create', { label: @_lastSearch }

typesMap =
  all: [ 'works', 'humans', 'series', 'users', 'groups' ]
  book: 'works'
  author: 'humans'
  serie: 'series'
  user: 'users'
  group: 'groups'
  subject: 'subjects'

filtersWithAlternatives = [ 'all', 'book', 'author', 'serie' ]

getTypeFromId = (id)-> id.replace 'filter-', ''

# Pre-formatting is required to set the type
# Taking the opportunity to omit all non-required data
formatSubject = (result)->
  id: result.id
  label: result.label
  description: result.description
  uri: "wd:#{result.id}"
  type: 'subjects'

formatEntity = (entity)->
  unless entity?.toJSON?
    error_.report 'cant format invalid entity', { entity }
    return

  data = entity.toJSON()
  data.image = data.image.url
  # Return a model to prevent having it re-formatted
  # as a Result model, which works from a result object, not an entity
  return new Backbone.Model data
