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
    { wd:@wdModels, inv:@invModels } = spreadByDomain works
    @candidates = @getCandidates()
    @showNextProbableDuplicates()

  getCandidates: ->
    candidates = {}

    @invModels.forEach addLabelsParts
    @wdModels.forEach addLabelsParts

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

    return _.values candidates
    .filter hasPossibleDuplicates
    .map (candidate)->
      # Sorting so that the first model is the closest
      candidate.possibleDuplicateOf.sort byMatchLength(invUri)
      return candidate

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

addLabelsParts =  (model)-> model._labelsParts or= getLabelsParts getFormattedLabels(model)

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


getLabelsParts = (labels)->
  parts = labels.map (label)->
    label
    .split titleSeparator
    # Filter-out parts that are just the serie name and the volume number
    .filter isntVolumeNumber
  return _.uniq _.flatten(parts)

titleSeparator = /\s*[-,:]\s+/
volumePattern = /(vol|volume|t|tome)\s\d+$/
isntVolumeNumber = (part)-> not volumePattern.test(part)

addCloseEntitiesToMergeCandidates = (invModel, candidates, otherModel)->
  invUri = invModel.get 'uri'
  partsA = invModel._labelsParts
  partsB = otherModel._labelsParts
  bestMatchScore = getBestMatchScore partsA, partsB
  if bestMatchScore > 0
    otherModel.bestMatchScore or= {}
    otherModel.bestMatchScore[invUri] = bestMatchScore
    candidates[invUri].possibleDuplicateOf.push otherModel

  return

getBestMatchScore = (aLabelsParts, bLabelsParts)->
  bestMatchScore = 0

  for aPart in aLabelsParts
    for bPart in bLabelsParts
      [ shortest, longest ] = getShortestAndLongest aPart.length, bPart.length
      # Do not compare parts that are very different in length
      if longest - shortest < 5
        distance = leven aPart, bPart
        if distance < 5
          matchScore = longest - distance
          if matchScore > bestMatchScore then bestMatchScore = matchScore

  return bestMatchScore

getShortestAndLongest = (a, b)-> if a > b then [ b, a ] else [ a, b ]

hasPossibleDuplicates = (candidate)->
  possibleCandidatesCount = candidate.possibleDuplicateOf.length
  # Also ignore when there are too many candidates
  return possibleCandidatesCount > 0 and possibleCandidatesCount < 10

byMatchLength = (invUri)->(a, b)-> b.bestMatchScore[invUri] - a.bestMatchScore[invUri]
