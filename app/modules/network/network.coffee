NetworkLayout = require './views/network_layout'
GroupBoard =  require './views/group_board'
initGroupHelpers = require './lib/group_helpers'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'network(/)': 'showNetworkLayout'
        'network/friends(/)': 'showNetworkLayoutFriends'
        'network/groups(/)': 'showNetworkLayoutGroups'
        'network/groups/:id(/:name)(/)': 'showGroupBoard'
        # group routes are in the inventory router

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.commands.setHandlers
      'show:network': API.showNetworkLayout
      'show:network:friends': API.showNetworkLayoutFriends
      'show:network:groups': API.showNetworkLayoutGroups
      'show:group:board': API.showGroupBoardFromModel

    app.reqres.setHandlers
      'get:network:counters': networkCounters

    app.request 'waitForUserData'
    .then initGroupHelpers
    .then initRequestsCollectionsEvent.bind(@)

initRequestsCollectionsEvent = ->
  if app.user.loggedIn
    @listenTo app.users.otherRequested, 'add remove', requestsUpdates
    @listenTo app.user.groups.mainUserInvited, 'add remove', requestsUpdates

API =
  showNetworkLayoutFriends: -> @showNetworkLayout 'friends'
  showNetworkLayoutGroups: -> @showNetworkLayout 'groups'
  showNetworkLayout: (tab="friends")->
    if app.request 'require:loggedIn', "network/#{tab}"
      app.layout.main.show new NetworkLayout
        title: _.i18n tab
        tab: tab

  # can be used to link to the group board from the group inventory
  showGroupBoard: (id, name)->
    # depend on group_helpers which waitForUserData
    app.request 'waitForUserData'
    .then -> app.request 'get:group:model', id
    .then showGroupBoardFromModel
    .catch (err)->
      _.error err, 'get:group:model err'
      app.execute 'show:404'

  showGroupBoardFromModel: (model)->
    [ id, name ] = model.gets '_id', 'name'
    route = "network/groups/#{id}/#{name}"
    showGroupBoardFromModel model
    app.navigate route

showGroupBoardFromModel = (model)->
  app.layout.main.show new GroupBoard
    model: model
    standalone: true

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
