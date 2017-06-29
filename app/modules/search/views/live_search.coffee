# TODO:
# - add 'help': indexed wiki.inventaire.io entries to give results
#   to searches such as 'FAQ' or 'help creating group'
# - add 'subjects': search Wikidata for entities that are used
#   as 'main subject' (wdt:P921)
# - add 'place': search Wikidata for entities with coordinates (wdt:P625)
#   and display a layout with users & groups nearby, as well as books with
#   narrative location (wdt:P840), or authors born (wdt:P19)
#   or dead (wdt:P20) nearby

Results = Backbone.Collection.extend { model: require('../models/result') }

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

  events:
    'click .searchFilter': 'updateFilters'

  onSpecialKey: (key)->
    switch key
      when 'up' then @highlightPrevious()
      when 'down' then @highlightNext()
      when 'enter' then @showCurrentlyHighlightedResult()
      when 'pageup' then @selectPrevFilter()
      when 'pagedown' then @selectNextFilter()
      else return

  updateFilters: (e)-> @selectFromTarget $(e.currentTarget)
  selectPrevFilter: -> @selectFromTarget @$el.find('.selected').prev()
  selectNextFilter: -> @selectFromTarget @$el.find('.selected').next()
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

  search: (search)->
    search = search?.trim()
    unless _.isNonEmptyString search then return
    @_lastSearch = search
    _.preq.get app.API.search(@getTypes(), search)
    .then @addResults.bind(@)

  getTypes: ->
    name = getTypeFromId @$el.find('.selected')[0].id
    return typesMap[name]

  addResults: (res)->
    @resetHighlightIndex()
    @collection.reset res.results
    if res.results.length is 0 then @$el.addClass 'results-0'
    else @$el.removeClass 'results-0'

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

  showCurrentlyHighlightedResult: ->
    hilightedView = @children.findByIndex @_currentHighlightIndex
    if hilightedView then hilightedView.showResult()
    else @triggerMethod 'enter:without:hightlighed:result'

  resetHighlightIndex: ->
    @$el.find('.highlight').removeClass 'highlight'
    @_currentHighlightIndex = -1

typesMap =
  all: [ 'works', 'humans', 'series', 'users', 'groups' ]
  book: 'works'
  author: 'humans'
  serie: 'series'
  user: 'users'
  group: 'groups'

getTypeFromId = (id)-> id.replace 'filter-', ''
