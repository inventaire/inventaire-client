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

    getNames()
    .then _.Log('NAMES')
    .then (names)=>
      name = names.shift()
      @getHomonymes name

  getHomonymes: (name)->
    searchHumans name, 100
    .then (humans)=>
      uris = humans
        .filter asNameMatch(name)
        .map (human)-> getEntityUri(human.id or human._id)

      app.request 'get:entities:models', { uris, refresh: true }
      .then _.Log('humans models')
      .then @collection.add.bind(@collection)

  events:
    'click .workLi': 'selectWork'
    'click .merge': 'mergeSelected'

  selectWork: (e)->
    $target = $(e.currentTarget)
    uri = getTargetUri e
    $currentlySelected = $('.selected-from, .selected-to')

    switch $currentlySelected.length
      when 0 then $target.addClass 'selected-from'
      when 1
        if $target[0] isnt $currentlySelected[0] then $target.addClass 'selected-to'
      else
        $currentlySelected.removeClass 'selected-from selected-to'
        $target.addClass 'selected-from'

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

getNames = ->
  _.preq.get app.API.entities.duplicates
  .get 'names'
