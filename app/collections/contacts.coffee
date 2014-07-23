module.exports = class Contacts extends Backbone.Collection
  model: require "../models/contact"
  url: 'contacts'

  filtered: (text)->
    return @filter (contact) ->
      filterExpr = new RegExp '^' + text, "i"
      return filterExpr.test contact.get('username')

  byId: (id)->
    @_byId[id]

  byUsername: (username)->
    @findWhere {username: username}