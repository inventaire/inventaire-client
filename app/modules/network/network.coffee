NetworkLayout = require './views/network_layout'
GroupBoard =  require './views/group_board'
initGroupHelpers = require './lib/group_helpers'
{ tabsData } = require './lib/network_tabs'
{ defaultTab } = require './lib/network_tabs'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'network(/users)(/search)(/)':'showSearchUsers'
        'network/users/friends(/)':'showFriends'
        'network/users/invite(/)':'showInvite'
        'network/users/nearby(/)':'showNearbyUsers'

        'network(/groups)(/search)(/)':'showSearchGroups'
        'network/groups/user(/)':'showUserGroups'
        'network/groups/create(/)':'showCreateGroup'
        'network/groups/nearby(/)':'showNearbyGroups'

        'network/groups/:id(/:name)(/)': 'showGroupBoard'

        # legacy redirections
        'network/friends(/)':'showFriends'

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.commands.setHandlers
      'show:network': API.showNetworkLayout
      'show:network:friends': API.showFriends
      'show:network:groups': API.showGroups
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
  # qs stands for query string
  showSearchUsers: (qs)-> API.showNetworkLayout 'searchUsers', qs
  showFriends: -> API.showNetworkLayout 'friends'
  showInvite: -> API.showNetworkLayout 'invite'
  showNearbyUsers: (qs)-> API.showNetworkLayout 'nearbyUsers', qs

  showSearchGroups: (qs)-> API.showNetworkLayout 'searchGroups', qs
  showUserGroups: -> API.showNetworkLayout 'userGroups'
  showCreateGroup: -> API.showNetworkLayout 'createGroup'
  showNearbyGroups: -> API.showNetworkLayout 'nearbyGroups'

  showNetworkLayout: (tab=defaultTab, qs)->
    { path } = tabsData.all[tab]
    query = if _.isNonEmptyString qs then _.parseQuery qs else {}
    if app.request 'require:loggedIn', _.buildPath(path, query)
      app.layout.main.show new NetworkLayout
        tab: tab
        query: query

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
