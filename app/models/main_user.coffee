Filterable = require 'models/filterable'

module.exports = class MainUser extends Filterable
  url: ->
    app.API.auth.user

  update: =>
    @sync 'update', @

  initialize: ->
    @setLang()
    @on 'change:language', @setLang

  setLang: => @lang = @get('language')