UserCommons = require 'modules/users/models/user_commons'
Transactions = require 'modules/transactions/collections/transactions'
Groups = require 'modules/network/collections/groups'
solveLang = require '../lib/solve_lang'
notificationsList = sharedLib 'notifications_settings_list'

module.exports = UserCommons.extend
  url: ->
    app.API.user

  parse: (data)->
    # _.log data, 'data:main user parse data'
    { notifications, relations, transactions, groups, settings } = data
    @addNotifications(notifications)
    data.settings = @setDefaultSettings settings
    @relations = relations
    @transactions = new Transactions transactions
    @groups = new Groups groups
    app.vent.trigger 'transactions:unread:changes'
    return _(data).omit ['relations', 'notifications', 'transactions', 'groups']

  initialize: ->
    @setLang()
    @on 'change:language', @setLang
    @on 'change:username', @setPathname

  setLang: -> @lang = solveLang @get('language')

  addNotifications: (notifications)->
    if notifications?
      app.request('waitForData')
      .then app.request.bind(app, 'notifications:add', notifications)

  setDefaultSettings: (settings)->
    settings.notifications = @setDefaultNotificationsSettings(settings.notifications)
    return settings

  setDefaultNotificationsSettings: (notifications)->
    notificationsList.forEach (notif)->
      notifications[notif] = notifications[notif] isnt false
    return _.log notifications, 'notifications'

  serializeData: ->
    attrs = @toJSON()
    attrs.mainUser = true
    attrs.inventoryLength = @inventoryLength()
    return attrs

