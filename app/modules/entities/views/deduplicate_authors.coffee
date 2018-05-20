searchType = require '../lib/sources/search_type'
{ getEntityUri } = require '../lib/sources/entities_uris_results'
searchHumans = searchType 'humans'
{ startLoading, stopLoading } = require 'modules/general/plugins/behaviors'

module.exports = Marionette.CompositeView.extend
  id: 'deduplicateAuthors'
  template: require './templates/deduplicate_authors'
  childViewContainer: '.authors'
  childView: require './author_layout'
  # Lazy empty view: not really fitting the context
  # but just showing that nothing was found
  emptyView: require 'modules/inventory/views/no_item'
  behaviors:
    Loading: {}

  childViewOptions:
    showActions: false

  initialize: ->
    @collection = new Backbone.Collection
    { name } = @options
    if name? then @showName name
    else @fetchNames()

  fetchNames: ->
    startLoading.call @, '.authors-loading'

    _.preq.get app.API.entities.duplicates
    .get 'names'
    .then _.Log('names')
    .tap stopLoading.bind(@)
    .then (names)=>
      @names = names
      @render()

  serializeData: -> { @names }

  events:
    'click .name': 'showNameFromEvent'

  showNameFromEvent: (e)->
    name = e.currentTarget.attributes['data-key'].value
    $(e.currentTarget).addClass 'visited'
    @showName name

  showName: (name)->
    @collection.reset()
    startLoading.call @, '.authors-loading'

    app.execute 'querystring:set', 'name', name

    @gethomonyms name
    .then stopLoading.bind(@)

  gethomonyms: (name)->
    searchHumans name, 100
    .then (humans)=>
      # If there are many candidates, keep only those that look the closest, if any
      if humans.length > 50
        subset = humans.filter asNameMatch(name)
        if subset.length > 1 then humans = subset

      # If there are still many candidates, truncate the list to make it less
      # resource intensive
      if humans.length > 50 then humans = humans[0..50]

      uris = humans.map (human)-> getEntityUri(human.id or human._id)

      app.request 'get:entities:models', { uris }
      .then _.Log('humans models')
      .then @collection.add.bind(@collection)

  setFilter: (filter)->
    @filter = filter
    @render()

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
