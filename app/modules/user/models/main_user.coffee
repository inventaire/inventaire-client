Filterable = require 'modules/general/models/filterable'

module.exports = MainUser = Filterable.extend
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

  setLang: -> @lang = @get('language')

  addNotifications: (notifications)->
    if notifications?
      cb = app.request.bind(app, 'notifications:add', notifications)
      app.request 'waitForData', cb

  serializeData: ->
    attrs = @toJSON()
    attrs.mainUser = true
    return attrs
