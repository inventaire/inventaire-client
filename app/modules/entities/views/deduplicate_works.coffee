getWorksMergeCandidates = require '../lib/get_works_merge_candidates'

DeduplicateWorksList = Marionette.CollectionView.extend
  className: 'deduplicateWorksList'
  childView: require './work_li'
  tagName: 'ul'
  # Lazy empty view: not really fitting the context
  # but just showing that nothing was found
  emptyView: require 'modules/inventory/views/no_item'
  childViewOptions:
    showAllLabels: true
    showActions: false
    # Re-rendering loses candidates selections
    preventRerender: true

module.exports = Marionette.LayoutView.extend
  className: 'deduplicateWorks'
  template: require './templates/deduplicate_works'
  regions:
    wd: '.wdWorks'
    inv: '.invWorks'

  initialize: ->
    { @mergedUris } = @options

  onShow: ->
    { works } = @options
    { wd: @wdModels, inv: @invModels } = spreadByDomain works
    @candidates = getWorksMergeCandidates @invModels, @wdModels
    @showNextProbableDuplicates()

  showNextProbableDuplicates: ->
    @$el.addClass 'probableDuplicatesMode'
    nextCandidate = @candidates.shift()
    unless nextCandidate? then return @next()
    { invModel, possibleDuplicateOf } = nextCandidate
    if invModel.get('uri') in @mergedUris then return @next()

    # Filter-out entities that where already merged
    # @_currentFilter will be undefined on the first candidate round
    # as no merged happened yet, thus no filter was set
    if @_currentFilter?
      possibleDuplicateOf = possibleDuplicateOf.filter @_currentFilter

    mostProbableDuplicate = possibleDuplicateOf[0]
    unless mostProbableDuplicate? then return @next()
    # If the candidate duplicate was filtered-out, go to the next step
    if mostProbableDuplicate.get('uri') in @mergedUris then return @next()

    { wd:wdModels, inv:invModels } = spreadByDomain possibleDuplicateOf
    @showList 'wd', wdModels
    @showList 'inv', [ invModel ].concat(invModels)
    # Give the views some time to initalize before expecting them
    # to be accessible in the DOM from their selectors
    @setTimeout @_showNextProbableDuplicatesUpdateUi.bind(@, invModel, mostProbableDuplicate), 200

  _showNextProbableDuplicatesUpdateUi: (invModel, mostProbableDuplicate)->
    @selectCandidates invModel, mostProbableDuplicate
    @$el.trigger 'next:button:show'

  selectCandidates: (from, to)->
    @$el.trigger 'entity:select',
      uri: from.get 'uri'
      direction: 'from'

    @$el.trigger 'entity:select',
      uri: to.get 'uri'
      direction: 'to'

  onMerge: -> @next()

  next: ->
    # Once we got to the full lists, do not re-generate lists views
    # as you might loose the filter state
    if @_listsShown then return

    if @candidates.length > 0 then @showNextProbableDuplicates()
    else @showLists()

  showLists: ->
    @$el.removeClass 'probableDuplicatesMode'
    @showList 'wd', @wdModels
    @showList 'inv', @invModels
    @$el.trigger 'next:button:hide'
    @_listsShown = true

  showList: (regionName, models, sort = true)->
    if models.length is 0 then return @[regionName].empty()
    if sort then models.sort sortAlphabetically
    collection = new Backbone.Collection models
    @[regionName].show new DeduplicateWorksList { collection }

  setFilter: (filter)->
    @_currentFilter = filter
    @filterSubView 'wd', filter
    @filterSubView 'inv', filter

    wdChildren = @wd.currentView.children
    invChildren = @inv.currentView.children
    if wdChildren.length is 1 and invChildren.length is 1
      wdModel = _.values(wdChildren._views)[0].model
      invModel = _.values(invChildren._views)[0].model
      @selectCandidates invModel, wdModel

  filterSubView: (regionName, filter)->
    view = @[regionName].currentView
    # Known case: when we are still at the 'probable duplicates' phase
    unless view? then return
    view.filter = filter
    view.render()

spreadByDomain = (models)-> models.reduce spreadWorks, { wd: [], inv: [] }

spreadWorks = (data, work)->
  prefix = work.get 'prefix'
  data[prefix].push work
  return data

sortAlphabetically = (a, b)->
  if a.get('label').toLowerCase() > b.get('label').toLowerCase() then 1
  else -1
