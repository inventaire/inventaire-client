searchType = require '../lib/sources/search_type'
{ getEntityUri } = require '../lib/sources/entities_uris_results'
searchHumans = searchType 'humans'
mergeEntities = require './editor/lib/merge_entities'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.CompositeView.extend
  id: 'deduplicateLayout'
  template: require './templates/deduplicate_layout'
  childViewContainer: '.authors'
  childView: require './author_layout'
  behaviors:
    AlertBox: {}
    Loading: {}

  initialize: ->
    @collection = new Backbone.Collection
    @fetchNames()

  fetchNames: ->
    _.preq.get app.API.entities.duplicates
    .get 'names'
    .then _.Log('names')
    .then (names)=>
      @names = names
      @render()

  serializeData: -> { @names }

  events:
    'click .name': 'showName'
    'click .workLi,.authorLayout': 'select'
    'click .merge': 'mergeSelected'

  showName: (e)->
    name = e.currentTarget.attributes['data-key'].value
    $(e.currentTarget).addClass 'visited'

    @collection.reset()
    startLoading.call @, '.authors-loading'

    @getHomonymes name
    .then stopLoading.bind(@)

  getHomonymes: (name)->
    searchHumans name, 100
    .then (humans)=>
      # If there are many candidates, keep only those that look the closest, if any
      if humans.length > 10
        subset = humans.filter asNameMatch(name)
        if subset.length > 1 then humans = subset

      # If there are still many candidates, truncate the list to make it less
      # resource intensive
      if humans.length > 10 then humans = humans[0..10]

      uris = humans.map (human)-> getEntityUri(human.id or human._id)

      app.request 'get:entities:models', { uris, refresh: true }
      .then _.Log('humans models')
      .then @collection.add.bind(@collection)

  select: (e)->
    $target = $(e.currentTarget)
    uri = getTargetUri e
    $currentlySelected = $('.selected-from, .selected-to')

    switch $currentlySelected.length
      when 0 then $target.addClass 'selected-from'
      when 1
        if $target[0] isnt $currentlySelected[0]
          if getElementType($target[0]) is getElementType($currentlySelected[0])
            $target.addClass 'selected-to'
          else
            $currentlySelected.removeClass 'selected-from selected-to'
            $target.addClass 'selected-from'
      else
        $currentlySelected.removeClass 'selected-from selected-to'
        $target.addClass 'selected-from'

    # Prevent a click on a work to also trigger an event on the author
    e.stopPropagation()

  mergeSelected: ->
    fromUri = getElementUri $('.selected-from')[0]
    toUri = getElementUri $('.selected-to')[0]

    unless fromUri? then return alert "no 'from' URI"
    unless toUri? then return alert "no 'to' URI"

    startLoading.call @, '.merge'

    mergeEntities fromUri, toUri
    .then ->
      hideMergedEntities()
      $('.selected-from').removeClass 'selected-from'
      $('.selected-to').removeClass 'selected-to'
    .finally stopLoading.bind(@)
    .catch error_.Complete('.merge', false)
    .catch forms_.catchAlert.bind(null, @)

getElementUri = (el)-> el?.attributes['data-uri'].value
getTargetUri = (e)-> getElementUri e.currentTarget
getElementType = (el)-> if $(el).hasClass('authorLayout') then 'author' else 'work'

asNameMatch = (name)-> (human)-> _.any _.values(human.labels), labelMatch(name)

labelMatch = (name)-> (label)-> normalize(label) is normalize(name)

normalize = (name)->
  name
  .trim()
  # Remove single letter for second names 'L.'
  .replace /\s\w{1}\.\s?/g, ' '
  # remove double spaces
  .replace /\s\s/g, ' '
  # remove special characters
  .replace /[.\/\\,]/g, ''
  .toLowerCase()

hideMergedEntities = ->
  $from = $('.selected-from')
  if $from.hasClass 'workLi'
    $author = $from.parents('.authorLayout')
    # If it was the last work, hide the whole author as it should have been turned
    # into a redirection
    if $author.find('.workLi').length is 1 then $author.hide()
    else $from.hide()
  else if $from.hasClass 'authorLayout'
    $from.hide()
