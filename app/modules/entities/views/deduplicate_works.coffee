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
    probableDuplicates: '.probableDuplicates'
    wd: '.wdWorks'
    inv: '.invWorks'

  onShow: ->
    { works } = @options
    _.log works, 'works'
    { wd:@wdModels, inv:@invModels } = works.reduce spreadWorks, { wd: [], inv: [] }
    @showNextProbableDuplicates()

  showNextProbableDuplicates: ->
    @wd.empty()
    @inv.empty()
    @candidates or= @getCandidates()
    nextCandidates = @candidates.shift()
    @showList 'probableDuplicates', nextCandidates, false
    [ wdModel, invModel ] = nextCandidates
    select invModel.get('uri'), 'from'
    select wdModel.get('uri'), 'to'

  getCandidates: ->
    candidates = []

    @invModels.forEach (model)-> model.labels or= getFormattedLabels model
    @wdModels.forEach (model)-> model.labels or= getFormattedLabels model

    for invModel in @invModels
      for wdModel in @wdModels
        [ distance, averageLength ] = getLowestDistance wdModel.labels, invModel.labels
        # If the distance between the closest labels is lower than 1/3 of the length
        # it's worth checking if it's a duplicate
        if distance <= averageLength / 3 then candidates.push [ wdModel, invModel ]

    return candidates

  onMerge: ->
    if @candidates.length > 0 then @showNextProbableDuplicates()
    else @showLists()

  showLists: ->
    @probableDuplicates.empty()
    @showList 'wd', @wdModels
    @showList 'inv', @invModels

  showList: (regionName, models, sort=true)->
    if sort then models.sort sortAlphabetically
    collection = new Backbone.Collection models
    @[regionName].show new DeduplicateWorksList { collection }

  setFilter: (filter)->
    @filterSubView 'wd', filter
    @filterSubView 'inv', filter

  filterSubView: (regionName, filter)->
    view = @[regionName].currentView
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
    .trim()

getLowestDistance = (aLabels, bLabels)->
  lowestDistance = Infinity
  averageLength = 0
  closestA = null
  closestB = null
  for aLabel in aLabels
    for bLabel in bLabels
      distance = leven aLabel, bLabel
      if distance < lowestDistance
        lowestDistance = distance
        averageLength = ( aLabel.length + bLabel.length ) / 2
  return [ lowestDistance, averageLength ]

# This is an intervention in what should be deduplicate_layout responsability
# TODO: trigger an event to which deduplicate_layout can react on for the same effect
select = (uri, direction)-> $("[data-uri='#{uri}']").addClass "selected-#{direction}"
