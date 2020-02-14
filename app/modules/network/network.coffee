Groups = require './collections/groups'
GroupBoard =  require './views/group_board'
initGroupHelpers = require './lib/group_helpers'
fetchData = require 'lib/data/fetch'
InviteByEmail = require './views/invite_by_email'
CreateGroupLayout = require './views/create_group_layout'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'groups/:id/settings(/)': 'showGroupBoard'

        # Legacy redirections
        'network/friends(/)': 'redirectToInventoryNetwork'
        'network(/users)(/)': 'redirectToInventoryNetwork'
        'network(/users)(/search)(/)': 'redirectToInventoryNetwork'
        'network/users/friends(/)': 'redirectToInventoryNetwork'
        'network/users/invite(/)': 'redirectToInventoryNetwork'
        'network/groups(/)': 'redirectToInventoryNetwork'
        'network/groups/search(/)': 'redirectToInventoryNetwork'
        'network/groups/user(/)': 'redirectToInventoryNetwork'
        'network/groups/settings(/)': 'redirectToInventoryNetwork'
        'network/users/nearby(/)': 'redirectToInventoryPublic'
        'network/groups/nearby(/)': 'redirectToInventoryPublic'
        'network/groups/create(/)': 'showCreateGroupLayout'
        'network/groups/settings/:id(/)': 'showGroupBoard'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.commands.setHandlers
      'show:group:create': API.showCreateGroup
      'show:group:board': showGroupBoardFromModel
      'show:invite:friend:by:email': API.showInviteFriendByEmail
      'create:group': API.showCreateGroupLayout

    app.reqres.setHandlers
      'get:network:invitations:count': getNetworkNotificationsCount

    fetchData
      name: 'groups'
      Collection: Groups
      condition: app.user.loggedIn

    app.request 'wait:for', 'user'
    .then initGroupHelpers
    .then initRequestsCollectionsEvent.bind(@)

initRequestsCollectionsEvent = ->
  if app.user.loggedIn
    app.request 'waitForNetwork'
    .then -> app.vent.trigger 'network:requests:update'

API =
  redirectToInventoryNetwork: -> app.execute 'show:inventory:network'
  redirectToInventoryPublic: -> app.execute 'show:inventory:public'

  # Named showGroupBoard and not showGroupSettings
  # as GroupSettings are a child view of GroupBoard
  showGroupBoard: (slug)->
    if app.request 'require:loggedIn', "groups/#{slug}/settings"
      app.request 'get:group:model', slug
      .then showGroupBoardFromModel
      .catch (err)->
        _.error err, 'get:group:model err'
        app.execute 'show:error:missing'

  showInviteFriendByEmail: -> app.layout.modal.show new InviteByEmail
  showCreateGroupLayout: -> app.layout.modal.show new CreateGroupLayout

showGroupBoardFromModel = (model, options = {})->
  if model.mainUserIsMember()
    model.beforeShow()
    .then ->
      { openedSection } = options
      app.layout.main.show new GroupBoard { model, standalone: true, openedSection }
      app.navigateFromModel model, 'boardPathname'
  else
    # If the user isnt a member, redirect to the standalone group inventory
    app.execute 'show:inventory:group', model, true

getNetworkNotificationsCount = ->
  # TODO: introduce a 'read' flag on the relation document to stop counting
  # requests that were already seen.
  friendsRequestsCount = app.relations.otherRequested.length
  mainUserInvitationsCount = app.groups.mainUserInvited.length
  return friendsRequestsCount + mainUserInvitationsCount
