UserCommons = require 'modules/users/models/user_commons'
solveLang = require '../lib/solve_lang'
notificationsList = sharedLib 'notifications_settings_list'
initI18n = require '../lib/i18n'
{ location } = window

module.exports = UserCommons.extend
  isMainUser: true
  url: ->
    app.API.user

  parse: (data)->
    data.settings = @setDefaultSettings data.settings
    return data

  initialize: ->
    @on 'change:language', @changeLang.bind(@)
    @on 'change:username', @setPathname.bind(@)

    # Only listening for first change (when the main user data arrive)
    # as next changes happening in deep objects won't trigger this event anyway
    @once 'change:snapshot', @setAllInventoryStats.bind(@)
    @on 'items:change', @updateItemsCounters.bind(@)

    # user._id should only change once from undefined to defined
    @once 'change:_id', (model, id)-> app.execute 'track:user:id', id

    # If the user is logged in, this will wait for her document to arrive
    # with its language attribute. Else, it will fire at next tick.
    app.request 'wait:for', 'user'
    .then @setLang.bind(@)

  setLang: ->
    @lang = solveLang @get('language')
    initI18n app, @lang

  # Two valid language change cases:
  # - The user isn't logged in and change the language from the top bar selector
  # - The user is logged in and change the language from her profile settings
  changeLang: ->
    unless app.polyglot? then return

    lang = @get 'language'
    if lang is app.polyglot.currentLocale then return

    reloadHref = window.location.href
    if app.request('querystring:get', 'lang')?
      # Prevent the querystring to override the language change
      # Can't just pass null to 'querystring:set' due to its limitations
      reloadHref = reloadHref
        .replace /&?lang=\w+/, ''
        # If all there is left from the querystring is a '?', remove it
        .replace /\?$/, ''

    reload = -> location.href = reloadHref

    if @loggedIn
      # wait for the server confirmation as we keep the language setting
      # in the user's document
      @once 'confirmed:language', reload
    else
      # the language setting is persisted as a cookie instead
      _.setCookie 'lang', lang
      .then reload

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
    if nonPrivate then @get('itemsCount') - @get('privateItemsCount')
    else @get 'itemsCount'

  updateItemsCounters: (previousListing, newListing)->
    snapshot = @get 'snapshot'
    if previousListing? then snapshot[previousListing]['items:count'] -= 1
    if newListing? then snapshot[newListing]['items:count'] += 1
    @set 'snapshot', snapshot
    @setAllInventoryStats()

  setAllInventoryStats: ->
    @setInventoryStats()
    @set 'privateItemsCount', @get('snapshot').private['items:count']

  deleteAccount: ->
    console.log 'starting to play "Somebody that I use to know" and cry a little bit'

    @destroy()
    .then -> app.execute 'logout'

  # maintain the API parity with other user models
  distanceFromMainUser: -> null
