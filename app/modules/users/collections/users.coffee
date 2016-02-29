module.exports = Backbone.Collection.extend
  model: require "../models/user"
  url: -> app.API.users.friends

  initialize: ->
    @lazyResort = _.debounce @sort.bind(@), 500
    # model events are also triggerend on parent collection
    @on 'change:highlightScore', @lazyResort

  comparator: 'highlightScore'

  filtered: (text)->
    return @filter (user) ->
      filterExpr = new RegExp '^' + text, "i"
      return filterExpr.test user.get('username')

  byUsername: (username)->
    @findWhere {username: username}
