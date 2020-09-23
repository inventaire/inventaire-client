behaviorsPlugin = require 'modules/general/plugins/behaviors'
alwaysFalse = -> false

module.exports = Marionette.CompositeView.extend
  behaviors:
    Loading: {}

  events:
    'inview .fetchMore': 'infiniteScroll'

  initInfiniteScroll: ->
    { @hasMore, @fetchMore } = @options
    @hasMore or= alwaysFalse
    @_fetching = false

  infiniteScroll: ->
    if @_fetching or not @hasMore() then return
    @_fetching = true
    @startLoading()

    @fetchMore()
    .then @stopLoading.bind(@)
    # Give the time for the DOM to update
    .delay 200
    .finally => @_fetching = false

  startLoading: -> behaviorsPlugin.startLoading.call @, '.fetchMore'
  stopLoading: -> behaviorsPlugin.stopLoading.call @, '.fetchMore'
