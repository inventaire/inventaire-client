Results = Backbone.Collection.extend { model: require('../models/result') }

module.exports = Marionette.CompositeView.extend
  id: 'live-search'
  template: require './templates/live_search'
  childViewContainer: 'ul.results'
  childView: require './result'

  initialize: -> @collection = new Results

  ui:
    all: '#checkbox-all'
    checkboxes: 'input[type="checkbox"]'

  events:
    'change input[type="checkbox"]': 'updateCheckBoxes'

  updateCheckBoxes: (e)->
    { id, checked } = e.currentTarget
    type = getTypeFromId id
    if type is @_lastType then return

    if checked
      _.toArray @ui.checkboxes
      .forEach (el)-> if el.id isnt id then el.checked = false
      if type is 'all' then @filter = null
      else @filter = (child)-> child.get('typeAlias') is type
    else
      @ui.all[0].checked = true
      @filter = null

    # Refresh the search with the new filters
    @search @_lastSearch
    @_lastType = type

  search: (search)->
    @_lastSearch = search
    unless _.isNonEmptyString search then return
    _.preq.get app.API.search(@getTypes(), search)
    .then @addResults.bind(@)

  getTypes: ->
    name = getTypeFromId @$el.find('input:checked')[0].id
    return typesMap[name]

  addResults: (res)->
    @resetHighlightIndex()
    @collection.reset res.results

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
    @children.findByIndex(@_currentHighlightIndex)?.showResult()

  resetHighlightIndex: -> @_currentHighlightIndex = -1

typesMap =
  all: [ 'works', 'humans', 'series', 'users', 'groups' ]
  book: 'works'
  author: 'humans'
  serie: 'series'
  user: 'users'
  group: 'groups'

getTypeFromId = (id)-> id.replace 'checkbox-', ''
