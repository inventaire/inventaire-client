# TODO:
# - hint to input ISBNs directly, maybe in the alternatives sections
# - add 'help': indexed wiki.inventaire.io entries to give results
#   to searches such as 'FAQ' or 'help creating group'
# - add 'place': search Wikidata for entities with coordinates (wdt:P625)
#   and display a layout with users & groups nearby, as well as books with
#   narrative location (wdt:P840), or authors born (wdt:P19)
#   or dead (wdt:P20) nearby

Results = Backbone.Collection.extend { model: require('../models/result') }
wikidataSearch = require 'modules/entities/lib/sources/wikidata_search'
findUri = require '../lib/find_uri'
error_ = require 'lib/error'
screen_ = require 'lib/screen'
searchBatchLength = 10
searchCount = 0

module.exports = Marionette.CompositeView.extend
  id: 'live-search'
  template: require './templates/live_search'
  childViewContainer: 'ul.results'
  childView: require './result'
  emptyView: require './no_result'

  initialize: ->
    @collection = new Results
    @_lazySearch = _.debounce @search.bind(@), 500
    { section: @selectedSectionName } = @options
    @_searchOffset = 0

  ui:
    all: '#section-all'
    sections: '.searchSection'
    resultsWrapper: '.resultsWrapper'
    results: 'ul.results'
    alternatives: '.alternatives'
    shortcuts: '.shortcuts'
    loader: '.loaderWrapper'

  serializeData: ->
    sections = sectionsData()
    selectedSectionName = if sections[@selectedSectionName]? then @selectedSectionName else 'all'
    sections[selectedSectionName].selected = true
    return { sections }

  events:
    'click .searchSection': 'updateSections'
    'click .deepSearch': 'showDeepSearch'
    'click .createEntity': 'showEntityCreate'

  onShow: ->
    # Doesn't work if set in events for some reason
    @ui.resultsWrapper.on 'scroll', @onResultsScroll.bind(@)

  onSpecialKey: (key)->
    switch key
      when 'up' then @highlightPrevious()
      when 'down' then @highlightNext()
      when 'enter' then @showCurrentlyHighlightedResult()
      when 'pageup' then @selectPrevSection()
      when 'pagedown' then @selectNextSection()
      else return

  updateSections: (e)-> @selectFromTarget $(e.currentTarget)

  selectPrevSection: -> @selectByPosition 'prev', 'last'
  selectNextSection: -> @selectByPosition 'next', 'first'
  selectByPosition: (relation, fallback)->
    $target = @$el.find('.selected')[relation]()
    if $target.length is 0 then $target = @$el.find('.sections a')[fallback]()
    @selectFromTarget $target

  selectFromTarget: ($target)->
    { id } = $target[0]
    isSelected = $target.hasClass 'selected'
    type = getTypeFromId id
    if type is @_lastType then return
    if isSelected
      $target.removeClass 'selected'
      @ui.all.addClass 'selected'
      @section = null
    else
      @ui.sections.removeClass 'selected'
      $target.addClass 'selected'
      if type is 'all' then @section = null
      else @section = (child)-> child.get('typeAlias') is type

    @_searchOffset = 0
    @_lastType = type
    # Refresh the search with the new sections
    if @_lastSearch? and @_lastSearch isnt '' then @lazySearch @_lastSearch

    @updateAlternatives type

  updateAlternatives: (type)->
    if type in sectionsWithAlternatives then @showAlternatives()
    else @hideAlternatives()

  search: (search)->
    search = search?.trim()
    @_lastSearch = search
    @_lastSearchId = ++searchCount
    @_searchOffset = 0

    unless _.isNonEmptyString search then return @hideAlternatives()

    uri = findUri search
    if uri? then return @getResultFromUri uri, @_lastSearchId

    @_search search
    .then @resetResults.bind(@, @_lastSearchId)

    @_waitingForAlternatives = true
    @setTimeout @showAlternatives.bind(@, search), 2000

  _search: (search)->
    types = @getTypes()
    # Subjects aren't indexed in the server ElasticSearch
    # as it's not a subset of Wikidata anymore: pretty much anything
    # on Wikidata can be considered a subject
    if types is 'subjects'
      wikidataSearch search, false, searchBatchLength, @_searchOffset
      .map formatSubject
    else
      # Increasing search limit instead of offset, as search pages aren't stable:
      # results popularity might have change the results order between two requests,
      # thus the need to re-fetch from offset 0 but increasing the page length, and adding only
      # the results that weren't returned in the previous query, whatever there place
      # in the newly returned results
      searchLimit = searchBatchLength + @_searchOffset
      _.preq.get app.API.search(types, search, searchLimit)
      .get 'results'

  lazySearch: (search)->
    if search.length > 0 then @showLoadingSpinner()
    # Hide previous results to limit confusion and scroll up
    @resetResults()
    @_lazySearch search

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

  getResultFromUri: (uri, searchId)->
    _.log uri, 'uri found'
    @showLoadingSpinner()

    app.request 'get:entity:model', uri
    .catch (err)->
      if err.message is 'entity_not_found' then return
      else throw err
    .finally @stopLoadingSpinner.bind(@)
    .then (entity)=> @resetResults searchId, [ formatEntity(entity) ]

  showLoadingSpinner: ->
    @ui.loader.html '<div class="small-loader"></div>'
    @$el.removeClass 'no-results'

  stopLoadingSpinner: -> @ui.loader.html ''

  getTypes: ->
    name = getTypeFromId @$el.find('.selected')[0].id
    return sectionToTypes[name]

  resetResults: (searchId, results)->
    # Ignore results from any search that isn't the latest search
    if searchId? and searchId isnt @_lastSearchId then return
    @resetHighlightIndex()
    if results? then @stopLoadingSpinner()
    if results? and results.length is 0
      @$el.addClass 'no-results'
    else
      @$el.removeClass 'no-results'
      @setTimeout @showShortcuts.bind(@), 1000

    # Track TypeErrors where Result model 'initialize' crashes
    try @collection.reset results
    catch err
      err.context ?= {}
      err.context.results = results
      throw err

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

      screen_.innerScrollTop @ui.results, view?.$el

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

  onResultsScroll: (e)->
    visibleHeight = @ui.resultsWrapper.height()
    { scrollHeight, scrollTop } = e.currentTarget
    scrollBottom = scrollTop + visibleHeight
    if scrollBottom is scrollHeight then @loadMore()

  loadMore: ->
    @showLoadingSpinner()
    @_searchOffset += searchBatchLength
    @_search @_lastSearch
    .then @addNewResults.bind(@)

  addNewResults: (results)->
    currentResultsUri = @collection.map (model)-> model.get('uri')
    newResults = results.filter (result)-> result.uri not in currentResultsUri
    @collection.add newResults

sectionToTypes =
  all: [ 'works', 'humans', 'series', 'users', 'groups' ]
  book: 'works'
  author: 'humans'
  serie: 'series'
  user: 'users'
  group: 'groups'
  subject: 'subjects'

sectionsWithAlternatives = [ 'all', 'book', 'author', 'serie' ]

getTypeFromId = (id)-> id.replace 'section-', ''

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
  data.image = data.image?.url
  # Return a model to prevent having it re-formatted
  # as a Result model, which works from a result object, not an entity
  return new Backbone.Model data

sectionsData = ->
  all: { label: 'all' }
  book: { label: 'book' }
  author: { label: 'author' }
  serie: { label: 'series_singular' }
  user: { label: 'user' }
  group: { label: 'group' }
  subject: { label: 'subject' }
