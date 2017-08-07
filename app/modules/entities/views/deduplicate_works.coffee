leven = require 'leven'

DeduplicateWorksList = Marionette.CollectionView.extend
  className: 'deduplicateWorksList'
  childView: require './work_li'
  tagName: 'ul'
  # Lazy empty view: not really fitting the context
  # but just showing that nothing was found
  emptyView: require 'modules/inventory/views/no_item'
  childViewOptions:
    showAllLabels: true

module.exports = Marionette.LayoutView.extend
  className: 'deduplicateWorks'
  template: require './templates/deduplicate_works'
  regions:
    wd: '.wdWorks'
    inv: '.invWorks'

  onShow: ->
    { works } = @options
    { wd:@wdModels, inv:@invModels } = spreadByDomain works
    @candidates = @getCandidates()
    @showNextProbableDuplicates()

  getCandidates: ->
    candidates = {}

    @invModels.forEach (model)-> model.labels or= getFormattedLabels model
    @wdModels.forEach (model)-> model.labels or= getFormattedLabels model

    # Regroup candidates by invModel
    for invModel in @invModels
      invUri = invModel.get 'uri'
      # invModel._alreadyPassed = true
      candidates[invUri] = { invModel, possibleDuplicateOf: [] }

      for wdModel in @wdModels
        addCloseEntitiesToMergeCandidates invModel, candidates, wdModel

      for otherInvModel in @invModels
        # Avoid adding duplicate candidates in both directions
        unless otherInvModel.get('uri') is invUri
          addCloseEntitiesToMergeCandidates invModel, candidates, otherInvModel

      # Sorting so that the first model is the closest
      candidates[invUri].possibleDuplicateOf.sort byDistance(invUri)

    return _.values(candidates).filter hasPossibleDuplicates

  showNextProbableDuplicates: ->
    @$el.addClass 'probableDuplicatesMode'
    nextCandidate = @candidates.shift()
    unless nextCandidate? then return @next()
    { invModel, possibleDuplicateOf } = nextCandidate

    # Filter-out entities that where already merged
    # @_currentFilter will be undefined on the first candidate round
    # as no merged happened yet, thus no filter was set
    if @_currentFilter?
      possibleDuplicateOf = possibleDuplicateOf.filter @_currentFilter

    mostProbableDuplicate = possibleDuplicateOf[0]
    # If the candidate duplicate was filtered-out, go to the next step
    unless mostProbableDuplicate? then @next()

    { wd:wdModels, inv:invModels } = spreadByDomain possibleDuplicateOf
    @showList 'wd', wdModels
    @showList 'inv', [ invModel ].concat(invModels)
    # Give the views some time to initalize before expecting them
    # to be accessible in the DOM from their selectors
    setTimeout @_showNextProbableDuplicatesUpdateUi.bind(@, invModel, mostProbableDuplicate), 200

  _showNextProbableDuplicatesUpdateUi: (invModel, mostProbableDuplicate)->
    @$el.trigger 'entity:select', { uri: invModel.get('uri'), direction: 'from' }
    @$el.trigger 'entity:select', { uri: mostProbableDuplicate.get('uri'), direction: 'to' }
    @$el.trigger 'next:button:show'

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

  showList: (regionName, models, sort=true)->
    if models.length is 0 then return
    if sort then models.sort sortAlphabetically
    collection = new Backbone.Collection models
    @[regionName].show new DeduplicateWorksList { collection }

  setFilter: (filter)->
    @_currentFilter = filter
    @filterSubView 'wd', filter
    @filterSubView 'inv', filter

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

getFormattedLabels = (model)->
  _.values model.get('labels')
  .map (label)->
    label.toLowerCase()
    # Remove anything after a '(' or a '['
    # as some titles might still have comments between parenthesis
    # ex: 'some book title (French edition)'
    .replace /(\(|\[).*$/, ''
    # Ignore leading articles as they are a big source of false negative match
    .replace /^(the|a|le|la|l'|der|die|das)\s/ig, ''
    .trim()

getLowestDistance = (aLabels, bLabels)->
  lowestDistance = Infinity
  averageLength = 0
  for aLabel in aLabels
    for bLabel in bLabels
      distance = leven aLabel, bLabel
      if distance < lowestDistance
        lowestDistance = distance
        averageLength = ( aLabel.length + bLabel.length ) / 2
  return [ lowestDistance, averageLength ]

addCloseEntitiesToMergeCandidates = (invModel, candidates, otherModel)->
  invUri = invModel.get 'uri'
  [ distance, averageLength ] = getLowestDistance otherModel.labels, invModel.labels
  # If the distance between the closest labels is lower than 1/3 of the length
  # it's worth checking if it's a duplicate
  if distance <= averageLength / 3
    otherModel.distances or= {}
    otherModel.distances[invUri] = distance
    candidates[invUri].possibleDuplicateOf.push otherModel

  return

hasPossibleDuplicates = (candidate)-> candidate.possibleDuplicateOf.length > 0
byDistance = (invUri)->(a, b)-> a.distances[invUri] - b.distances[invUri]
