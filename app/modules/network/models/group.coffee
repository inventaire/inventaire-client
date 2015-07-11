error_ = require 'lib/error'

module.exports = Backbone.Model.extend
  url: app.API.groups
  initialize: ->
    { _id, name } = @toJSON()
    @set 'pathname', "/groups/#{_id}/#{name}"

    @initUsersCollection()

    # keep internal lists updated
    @on 'change:members change:admins', @_listAllMembers.bind(@)
    # keep @users udpated
    @on 'change:members change:admins', @initUsersCollection.bind(@)
    @on 'change:invited', @_listAllInvited.bind(@)

  initUsersCollection: ->
    # remove all users
    # to re-add all of them
    # while keeping the same object to avoid breaking references
    @users or= new Backbone.Collection
    @users.remove @users.models
    @allMembers().forEach @fetchUser.bind(@)

  fetchUser: (userId)->
    app.request 'get:group:user:model', userId
    .then @users.add.bind(@users)
    .catch _.Error('fetchMembers')

  allMembers: -> @_allMembers or @_listAllMembers()
  _listAllMembers: ->
    @_allMembers = @getUserIds('members').concat @getUserIds('admins')
  allInvited: -> @_allInvited or @_listAllInvited()
  _listAllInvited: -> @_allInvited = @getUserIds 'invited'
  allRequested: -> @_allRequested = @_listAllRequested()
  _listAllRequested: -> @_allRequested = @getUserIds 'requested'

  getUserIds: (category)->
    @get(category).map _.property('user')

  membersCount: ->
    @allMembers().length

  itemsCount: ->
    @users
    .map (user)-> user.inventoryLength() or 0
    .sum()

  serializeData: ->
    attrs = @toJSON()
    status = @mainUserStatus()
    attrs[status] = true
    _.extend attrs,
      publicDataOnly: @publicDataOnly
      membersCount: @membersCount()
      # itemsCount isnt available for public groups
      # due to an unsolved issue with user:inventoryLength in this case
      itemsCount: @itemsCount()  unless @publicDataOnly

  inviteUser: (user)->
    _.type user, 'object'
    _.preq.put app.API.groups,
      action: 'invite'
      group: @id
      user: user.id
    .then @updateInvited.bind(@, user)
    # let views catch the error

  updateInvited: (user)->
    @push 'invited',
      user: user.id
      invitor: app.user.id
      timestamp: _.now()
    user.trigger 'group:invite'

  userStatus: (user)->
    { id } = user
    if id in @allMembers() then return 'member'
    else if id in @allInvited() then return 'invited'
    else if id in @allRequested() then return 'requested'
    else 'none'

  mainUserStatus: -> @userStatus app.user
  mainUserIsMember: -> app.user.id in @allMembers()
  mainUserIsInvited: -> app.user.id in @allInvited()

  findMembership: (category, user)->
    _.findWhere @get(category), {user: user.id}

  findInvitation: (user)->
    @findMembership 'invited', user

  findUserInvitor: (user)->
    invitation = @findInvitation user
    if invitation?
      return app.request 'get:userModel:from:userId', invitation.invitor

  findMainUserInvitor: -> @findUserInvitor app.user

  acceptInvitation: ->
    @moveMembership app.user, 'invited', 'members'

    _.preq.put app.API.groups,
      action: 'accept'
      group: @id
    .then @fetchGroupUsersMissingItems.bind(@)
    .catch @revertMove.bind(@, app.user, 'invited', 'members')

  declineInvitation: ->
    @moveMembership app.user, 'invited', 'declined'

    _.preq.put app.API.groups,
      action: 'decline'
      group: @id
    .catch @revertMove.bind(@, app.user, 'invited', 'declined')

  # moving membership object from previousCategory to newCategory
  moveMembership: (user, previousCategory, newCategory)->
    membership = @findMembership previousCategory, user
    unless membership? then error_.new 'membership not found', arguments

    @without previousCategory, membership
    # let the possibility to just destroy the doc
    # by letting newCategory undefined
    if newCategory? then @push newCategory, membership

    if app.request 'user:isMainUser', user.id
      app.vent.trigger 'group:main:user:move'

  revertMove: (user, previousCategory, newCategory, err)->
    @moveMembership user, newCategory, previousCategory
    throw err

  fetchGroupUsersMissingItems: ->
    groupNonFriendsUsersIds = app.request 'get:non:friends:ids', @allMembers()
    _.log groupNonFriendsUsersIds, 'groupNonFriendsUsersIds'
    _.preq.get app.API.users.items(groupNonFriendsUsersIds)
    .then _.Log('groupNonFriendsUsers items')
    .then Items.add.bind(Items)
    .catch _.Error('fetchGroupUsersMissingItems err')

  requestToJoin: ->
    @push 'requested', @createRequest()

    _.preq.put app.API.groups,
      action: 'request'
      group: @id
    .catch @revertMove.bind(@, app.user, null, 'requested')

  createRequest: ->
    user: app.user.id
    timestamp: _.now()