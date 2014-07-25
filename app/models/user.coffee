module.exports = class User extends Backbone.Model
  defaults:
    contacts: []
  #   language: window.navigator.language || 'en'

  url: ->
    app.API.auth.user

  update: =>
    @sync 'update', @