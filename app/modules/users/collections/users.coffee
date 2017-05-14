module.exports = Backbone.Collection.extend
  model: require "../models/user"
  url: -> app.API.users.friends

  initialize: ->
    @lazyResort = _.debounce @sort.bind(@), 500
    # model events are also triggerend on parent collection
    @on 'change:highlightScore', @lazyResort

  comparator: 'highlightScore'

  # Include cids, but that's probably still faster than doing a map on models
  allIds: -> Object.keys app.users._byId
