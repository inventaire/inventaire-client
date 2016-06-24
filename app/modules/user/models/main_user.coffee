UserCommons = require 'modules/users/models/user_commons'
Transactions = require 'modules/transactions/collections/transactions'
Groups = require 'modules/network/collections/groups'
solveLang = require '../lib/solve_lang'
notificationsList = sharedLib 'notifications_settings_list'
initI18n = require '../lib/i18n'
{ location } = window

module.exports = UserCommons.extend
  isMainUser: true
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
    @on 'change:language', @changeLang.bind(@)
    @on 'change:username', @setPathname.bind(@)
    @on 'change:position', @setLatLng.bind(@)
    # user._id should only change once from undefined to defined
    @once 'change:_id', (model, id)-> app.execute 'track:user:id', id

    # If the user is logged in, this will wait for her document to arrive
    # with its language attribute. Else, it will fire at next tick.
    app.request 'waitForUserData'
    .then @setLang.bind(@)

  setLang: ->
    @lang = lang = solveLang @get('language')
    initI18n app, lang

  # Two valid language change cases:
  # - The user isn't logged in and change the language from the top bar selector
  # - The user is logged in and change the language from her profile settings
  changeLang: ->
    unless app.polyglot? then return

    lang = @get 'language'
    if lang is app.polyglot.currentLocale then return

    reload = location.reload.bind location

    if @loggedIn
      # wait for the server confirmation as we keep the language setting
      # in the user's document
      @once 'confirmed:language', ->
        app.entities.data.reset()
        .then reload
    else
      Promise.all [
        # the language setting is persisted as a cookie instead
        _.setCookie 'lang', lang
        app.entities.data.reset()
      ]
      .then reload

  addNotifications: (notifications)->
    if notifications?
      app.request 'waitForData'
      .then app.Request('notifications:add', notifications)

  setDefaultSettings: (settings)->
    { notifications } = settings
    settings.notifications = @setDefaultNotificationsSettings notifications
    return settings

  setDefaultNotificationsSettings: (notifications)->
    for notif in notificationsList
      notifications[notif] = notifications[notif] isnt false
    return notifications

  serializeData: (nonPrivate)->
    attrs = @toJSON()
    attrs.mainUser = true
    attrs.inventoryLength = @inventoryLength nonPrivate
    return attrs

  inventoryLength: (nonPrivate)->
    if @itemsFetched then app.request 'inventory:main:user:length', nonPrivate

  deleteAccount: ->
    console.log 'starting to play "Somebody that I use to know" and cry a little bit'

    _.preq.wrap @destroy()
    .then -> app.execute 'logout'

  # maintain the API parity with other user models
  distanceFromMainUser: -> null
