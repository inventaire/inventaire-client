NetworkLayout = require './views/network_layout'
GroupBoard =  require './views/group_board'
initGroupHelpers = require './lib/group_helpers'
{ tabsData } = require './lib/network_tabs'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'network(/users)(/search)(/)':'showNetworkLayoutSearchUsers'
        'network/users/friends(/)':'showNetworkLayoutFriends'
        'network/users/invite(/)':'showNetworkLayoutInvite'
        'network/users/nearby(/)':'showNetworkLayoutNearbyUsers'

        'network(/groups)(/search)(/)':'showNetworkLayoutSearchGroups'
        'network/groups/user(/)':'showNetworkLayoutUserGroups'
        'network/groups/create(/)':'showNetworkLayoutCreateGroup'
        'network/groups/nearby(/)':'showNetworkLayoutNearbyGroups'

        'network/groups/:id(/:name)(/)': 'showGroupBoard'

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
    app.request 'waitForData'
    .then -> app.vent.trigger 'network:requests:udpate'

API =
  showNetworkLayoutFriends: -> @showNetworkLayout 'friends'
  showNetworkLayoutInvite: -> @showNetworkLayout 'invite'
  showNetworkLayoutSearchUsers: -> @showNetworkLayout 'searchUsers'
  showNetworkLayoutNearbyUsers: -> @showNetworkLayout 'nearbyUsers'

  showNetworkLayoutUserGroups: -> @showNetworkLayout 'userGroups'
  showNetworkLayoutCreateGroup: -> @showNetworkLayout 'createGroup'
  showNetworkLayoutSearchGroups: -> @showNetworkLayout 'searchGroups'
  showNetworkLayoutNearbyGroups: -> @showNetworkLayout 'nearbyGroups'

  showNetworkLayout: (tab='friends')->
    { path } = tabsData.all[tab]
    if app.request 'require:loggedIn', path
      app.layout.main.show new NetworkLayout
        tab: tab

  showGroupBoard: (id, name)->
    # depend on group_helpers which waitForUserData
    app.request 'waitForUserData'
    .then -> app.request 'get:group:model', id
    .then showGroupBoardFromModel
    .catch (err)->
      _.error err, 'get:group:model err'
      app.execute 'show:404'

  showGroupBoardFromModel: (model)->
    showGroupBoardFromModel model
    app.navigate model.get('boardPathname')

showGroupBoardFromModel = (group)->
  if group.mainUserIsMember()
    app.layout.main.show new GroupBoard
      model: group
      standalone: true
  else
    # if the user isnt a member, redirect to the group inventory
    app.execute 'show:inventory:group', group

networkCounters = ->
  friendsRequestsCount = app.users.otherRequested?.length or 0
  { groups } = app.user
  mainUserInvitationsCount = groups?.mainUserInvited.length or 0
  otherUsersRequestsCount = groups?.otherUsersRequestsCount() or 0
  groupsRequestsCount = mainUserInvitationsCount + otherUsersRequestsCount
  return counters =
    friendsRequestsCount: counterUnlessZero friendsRequestsCount
    groupsRequestsCount: counterUnlessZero groupsRequestsCount
    total: counterUnlessZero(friendsRequestsCount + groupsRequestsCount)

counterUnlessZero = (count)->
  if count is 0 then return
  else return count
