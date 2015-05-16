Filterable = require 'modules/general/models/filterable'
Transactions = require 'modules/transactions/collections/transactions'

module.exports = MainUser = Filterable.extend
  url: ->
    app.API.user

  parse: (data)->
    _.log data, 'data:main user parse data'
    { notifications, relations, transactions } = data
    @addNotifications(notifications)
    @relations = relations
    @transactions = new Transactions transactions
    return _(data).omit ['relations', 'notifications', 'transactions']

  update: =>
    @sync 'update', @

  initialize: ->
    @setLang()
    @on 'change:language', @setLang

  setLang: -> @lang = @get('language')?[0..1]

  addNotifications: (notifications)->
    if notifications?
      app.request('waitForData')
      .then app.request.bind(app, 'notifications:add', notifications)

  serializeData: ->
    attrs = @toJSON()
    attrs.mainUser = true
    return attrs
