module.exports = class Contacts extends Backbone.Collection
  model: require "../models/contact"
  url: -> app.API.contacts.contacts

  filtered: (text)->
    return @filter (contact) ->
      filterExpr = new RegExp '^' + text, "i"
      return filterExpr.test contact.get('username')

  byUsername: (username)->
    @findWhere {username: username}