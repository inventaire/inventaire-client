behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.CompositeView.extend
  id: 'changeLayout'
  template: require './templates/changes_layout'
  childViewContainer: '#feed'
  childView: require './feed_li'
  initialize: ->
    @collection = new Backbone.Collection
    @fetchingMore = true

    fetchChanges()
    .then @parseResponse.bind(@)

  behaviors:
    Loading: {}

  ui:
    counter: '.counter'

  events:
    'inview .more': 'showMoreUnlessAlreadyFetching'

  parseResponse: (uris)->
    @rest = uris
    @showMore()

  showMore: (batchLength=10)->
    @fetchingMore = true
    # Don't fetch more and keep fetchingMore to true to prevent further requests
    if @rest.length is 0 then return
    behaviorsPlugin.startLoading.call @, '.more'
    batch = @rest[0...batchLength]
    @rest = @rest[batchLength..-1]
    @addFromUris batch

  showMoreUnlessAlreadyFetching: -> unless @fetchingMore then @showMore()

  addFromUris: (uris)->
    app.request 'get:entities:models', { uris }
    .then @collection.add.bind(@collection)
    .then @doneFetching.bind(@)

  doneFetching: ->
    @fetchingMore = false
    behaviorsPlugin.stopLoading.call @
    @ui.counter.html @collection.length

fetchChanges = ->
  _.preq.get app.API.entities.changes
  .get 'uris'
