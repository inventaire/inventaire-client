Filterable = require 'modules/general/models/filterable'

module.exports = class MainUser extends Filterable
  url: ->
    app.API.auth.user

  parse: (data)->
    app.request 'notifications:add', data.notifications
    @relations = data.relations
    return _(data).omit ['relations', 'notifications']

  update: =>
    @sync 'update', @

  initialize: ->
    @setLang()
    @on 'change:language', @setLang

  setLang: => @lang = @get('language')