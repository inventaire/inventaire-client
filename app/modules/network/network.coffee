NetworkLayout = require './views/network_layout'
initGroupHelpers = require './lib/group_helpers'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'network(/)': 'showNetworkLayout'
        'network/friends(/)': 'showNetworkLayoutFriends'
        'network/groups(/)': 'showNetworkLayoutGroups'
        # group routes are in the inventory router

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.commands.setHandlers
      'show:network': API.showNetworkLayout
      'show:network:friends': API.showNetworkLayoutFriends
      'show:network:groups': API.showNetworkLayoutGroups

    app.reqres.setHandlers
      'get:network:counters': networkCounters

    # app.user.group will be undefined if the user isnt loggedin
    if app.user.loggedIn
      app.request('waitForUserData')
      .then initGroupHelpers
      .then initRequestsCollectionsEvent.bind(@)

initRequestsCollectionsEvent = ->
  @listenTo app.users.otherRequested, 'add remove', requestsUpdates
  @listenTo app.user.groups.mainUserInvited, 'add remove', requestsUpdates

API =
  showNetworkLayoutFriends: -> @showNetworkLayout 'friends'
  showNetworkLayoutGroups: -> @showNetworkLayout 'groups'
  showNetworkLayout: (tab="friends")->
    if app.request 'require:loggedIn', "network/#{tab}"
      app.layout.main.Show new NetworkLayout
        title: _.i18n tab
        tab: tab

networkCounters = ->
  friendsRequestsCount = app.users.otherRequested?.length or 0
  groupsRequestsCount = app.user.groups?.mainUserInvited.length or 0
  return counters =
    friendsRequestsCount: counterUnlessZero friendsRequestsCount
    groupsRequestsCount: counterUnlessZero groupsRequestsCount
    total: counterUnlessZero(friendsRequestsCount + groupsRequestsCount)

counterUnlessZero = (count)->
  if count is 0 then return
  else return count

requestsUpdates = -> app.vent.trigger 'network:requests:udpate'
