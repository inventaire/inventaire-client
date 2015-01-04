Filterable = require 'modules/general/models/filterable'

module.exports = class MainUser extends Filterable
  url: ->
    app.API.user

  parse: (data)->
    _.log data, 'data:main user parse data'
    {notifications, relations} = data
    @addNotifications(notifications)
    @relations = relations
    return _(data).omit ['relations', 'notifications']

  update: =>
    @sync 'update', @

  initialize: ->
    @setLang()
    @on 'change:language', @setLang

  setLang: => @lang = @get('language')

  addNotifications: (notifications)->
    if notifications?
      app.request 'waitForData', app.request, app, 'notifications:add',notifications
