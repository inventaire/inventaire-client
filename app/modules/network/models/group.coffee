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

  getUserIds: (category)->
    @get(category).map _.property('user')

  membersCount: ->
    @allMembers().length

  itemsCount: ->
    @users
    .map (user)-> user.inventoryLength()
    .reduce (a, b)-> a + b

  serializeData: ->
    _.extend @toJSON(),
      membersCount: @membersCount()
      itemsCount: @itemsCount()

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
    invitation = @findMembership previousCategory, user
    unless invitation? then error_.new 'membership not found', arguments
    @without previousCategory, invitation
    @push newCategory, invitation
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
