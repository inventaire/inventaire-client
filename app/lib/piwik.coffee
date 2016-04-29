# expected to be a global variable by piwik.js
window._paq or= []
{ _paq, env } = window
trackerUrl = require('lib/urls').tracker

module.exports = ->
  # - radically prevents recording development actions
  # - reduces the load on the real tracker server
  # - easier debug
  # /!\ no request is made from users recognized as admin on the piwik
  if env is 'dev' then trackerUrl = app.API.tests

  _paq.push ['enableLinkTracking']
  _paq.push ['setTrackerUrl', trackerUrl]
  _paq.push ['setSiteId', 11]

  tracker = Piwik.getAsyncTracker()

  setUserId = (id)->
    if _.isUserId id then _paq.push ['setUserId', id]

  trackPageView = (title)->
    tracker.setCustomUrl location.href
    _paq.push ['trackPageView', title]

  # args: category, action, name, value
  trackEvent = (args...)->
    args = _.compact args
    ev = ['trackEvent'].concat args
    _paq.push ev

  signup = (type)-> trackEvent 'auth', 'signup', type
  login = (type)-> trackEvent 'auth', 'login', type
  # name spacing events actions as the piwik interface doesn't allow to do composed filter (like Category x && Action y)
  # and action names them self collide between categories
  transaction = (action, userStatus)-> trackEvent 'transaction', "transaction:#{action}", userStatus
  friend = (action)-> trackEvent 'friend', "friend:#{action}"
  invitation = (action, count)-> trackEvent 'invitation', "invitation:#{action}", 'count', count
  group = (action)-> trackEvent 'group', "group:#{action}"
  item = (action, listing, transaction)-> trackEvent 'item', "item:#{action}", listing, transaction

  app.commands.setHandlers
    'track:user:id': setUserId
    # debouncing to get only one page view reported
    # when successive document:title:change occure
    # and let the time to the route to be updated
    # (app.navigate being often trigger after all the actions are done)
    'track:page:view': _.debounce trackPageView, 300
    'track:auth:signup': signup
    'track:auth:login': login
    'track:transaction': transaction
    'track:friend': friend
    'track:invitation': invitation
    'track:group': group
    'track:item': item
