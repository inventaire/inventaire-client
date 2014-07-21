module.exports = class User extends Backbone.Model
  defaults:
    contacts: []
  #   language: window.navigator.language || 'en'

  url: -> 'user'

  update: =>
    @sync 'update', @

  isMainUser: -> @has 'email'