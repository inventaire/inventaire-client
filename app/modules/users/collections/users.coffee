module.exports = Backbone.Collection.extend
  model: require "../models/user"
  url: -> app.API.users.friends

  filtered: (text)->
    return @filter (user) ->
      filterExpr = new RegExp '^' + text, "i"
      return filterExpr.test user.get('username')

  byUsername: (username)->
    @findWhere {username: username}
