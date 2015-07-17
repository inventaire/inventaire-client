error_ = require 'lib/error'
# defining all and _recalculateAll methods
aggregateUsersIds = require '../lib/aggregate_users_ids'
groupActions = require '../lib/group_actions'

module.exports = Backbone.Model.extend
  url: app.API.groups
  initialize: ->
    aggregateUsersIds.call @
    _.extend @, groupActions

    { _id, name } = @toJSON()
    @set 'pathname', "/groups/#{_id}/#{name}"

    # non persisted category used for convinience on client-side
    @set 'tmp', []

    @initUsersCollection()

    # keep internal lists updated
    @on 'change:members change:admins', @_recalculateAllMembers.bind(@)
    @on 'change:invited', @_recalculateAllInvited.bind(@)
    # keep @users udpated
    @on 'change:members change:admins', @initUsersCollection.bind(@)

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
    # not using status alone as that would override users lists:
    # requested, invited etc
    attrs["status_#{status}"] = true
    _.extend attrs,
      publicDataOnly: @publicDataOnly
      membersCount: @membersCount()
      # itemsCount isnt available for public groups
      # due to an unsolved issue with user:inventoryLength in this case
      itemsCount: @itemsCount()  unless @publicDataOnly

  userStatus: (user)->
    { id } = user
    if id in @allMembers() then return 'member'
    else if id in @allInvited() then return 'invited'
    else if id in @allRequested() then return 'requested'
    else 'none'

  mainUserStatus: -> @userStatus app.user
  mainUserIsAdmin: -> app.user.id in @allAdmins()
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

  fetchGroupUsersMissingItems: ->
    groupNonFriendsUsersIds = app.request 'get:non:friends:ids', @allMembers()
    _.log groupNonFriendsUsersIds, 'groupNonFriendsUsersIds'
    _.preq.get app.API.users.items(groupNonFriendsUsersIds)
    .then _.Log('groupNonFriendsUsers items')
    .then Items.add.bind(Items)
    .catch _.Error('fetchGroupUsersMissingItems err')
