module.exports = class User extends Backbone.Model
  defaults:
    contacts: []

  url: ->
    app.API.auth.user

  update: =>
    @sync 'update', @

  initialize: ->
    @setLang()
    @on 'change:language', @setLang

  setLang: => @lang = @get('language')