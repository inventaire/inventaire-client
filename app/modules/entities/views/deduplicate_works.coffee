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
    _.log works, 'works'
    { wd:@wdModels, inv:@invModels } = works.reduce spreadWorks, { wd: [], inv: [] }
    @showNextProbableDuplicates()

  showNextProbableDuplicates: ->
    @$el.addClass 'probableDuplicatesMode'
    @candidates or= @getCandidates()
    nextCandidate = @candidates.shift()
    { invModel, wdModels } = nextCandidate
    wdModel = nextCandidate.wdModels[0]
    @showList 'wd', wdModels
    @showList 'inv', [ invModel ]
    # Give the views some time to initalize before expecting them
    # to be accessible in the DOM from their selectors
    setTimeout @_showNextProbableDuplicatesUpdateUi.bind(@, invModel, wdModel), 200

  _showNextProbableDuplicatesUpdateUi: (invModel, wdModel)->
    @$el.trigger 'entity:select', { uri: invModel.get('uri'), direction: 'from' }
    @$el.trigger 'entity:select', { uri: wdModel.get('uri'), direction: 'to' }
    @$el.trigger 'next:button:show'

  getCandidates: ->
    candidates = {}

    @invModels.forEach (model)-> model.labels or= getFormattedLabels model
    @wdModels.forEach (model)-> model.labels or= getFormattedLabels model

    # Regroup candidates by invModel
    for invModel in @invModels
      invUri = invModel.get 'uri'
      candidates[invUri] = { invModel, wdModels: [], closestDistance: Infinity }
      for wdModel in @wdModels
        [ distance, averageLength ] = getLowestDistance wdModel.labels, invModel.labels
        # If the distance between the closest labels is lower than 1/3 of the length
        # it's worth checking if it's a duplicate
        if distance <= averageLength / 3
          wdModel.distance = distance
          candidates[invUri].wdModels.push wdModel

      # Sorting so that the first model is the closest
      candidates[invUri].wdModels.sort (a, b)-> a.distance - b.distance

    return _.values(candidates).filter (candidate)-> candidate.wdModels.length > 0

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
    if sort then models.sort sortAlphabetically
    collection = new Backbone.Collection models
    @[regionName].show new DeduplicateWorksList { collection }

  setFilter: (filter)->
    @filterSubView 'wd', filter
    @filterSubView 'inv', filter

  filterSubView: (regionName, filter)->
    view = @[regionName].currentView
    # Known case: when we are still at the 'probable duplicates' phase
    unless view? then return
    view.filter = filter
    view.render()

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
