error_ = require 'lib/error'
# defining all and _recalculateAll methods
aggregateUsersIds = require '../lib/aggregate_users_ids'
groupActions = require '../lib/group_actions'
defaultCover = require('lib/urls').images.bokeh

module.exports = Backbone.Model.extend
  url: app.API.groups.private
  initialize: ->
    aggregateUsersIds.call @
    _.extend @, groupActions

    { _id, name } = @toJSON()
    pathname = "/groups/#{_id}/#{name}"
    @set 'pathname', pathname
    @set 'settingsPathname', "/network#{pathname}"

    # non persisted category used for convinience on client-side
    @set 'tmp', []

    @initMembersCollection()
    @initRequestersCollection()

    # keep internal lists updated
    @on 'change:members change:admins', @_recalculateAllMembers.bind(@)
    @on 'change:invited', @_recalculateAllInvited.bind(@)
    @on 'change:requested', @_recalculateAllRequested.bind(@)
    # keep @members udpated
    @on 'change:members change:admins', @initMembersCollection.bind(@)
    @on 'change:requested', @initRequestersCollection.bind(@)

  initMembersCollection: -> @initUsersCollection 'members'
  initRequestersCollection: -> @initUsersCollection 'requested'
  initUsersCollection: (name)->
    # remove all users
    # to re-add all of them
    # while keeping the same object to avoid breaking references
    @[name] or= new Backbone.Collection
    @[name].remove @[name].models
    Name = _.capitaliseFirstLetter name
    @["all#{Name}"]().forEach @fetchUser.bind(null, @[name])

  fetchUser: (collection, userId)->
    app.request 'get:group:user:model', userId
    .then collection.add.bind(collection)
    .catch _.Error('fetchMembers')

  getUserIds: (category)->
    @get(category).map _.property('user')

  membersCount: ->
    @allMembers().length

  itemsCount: ->
    @members
    .map userItemsCount
    .sum()

  serializeData: ->
    attrs = @toJSON()
    status = @mainUserStatus()
    # not using status alone as that would override users lists:
    # requested, invited etc
    attrs.picture or= defaultCover
    attrs["status_#{status}"] = true
    _.extend attrs,
      publicDataOnly: @publicDataOnly
      membersCount: @membersCount()
      # itemsCount isnt available for public groups
      # due to an unsolved issue with user:inventoryLength in this case
      itemsCount: @itemsCount()  unless @publicDataOnly
      mainUserIsAdmin: @mainUserIsAdmin()

  userStatus: (user)->
    { id } = user
    if id in @allMembers() then return 'member'
    else if id in @allInvited() then return 'invited'
    else if id in @allRequested() then return 'requested'
    else 'none'

  userIsAdmin: (userId)->
    return userId in @allAdmins()

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
    if groupNonFriendsUsersIds.length > 0
      _.preq.get app.API.users.items(groupNonFriendsUsersIds)
      .then _.Log('groupNonFriendsUsers items')
      .then Items.add.bind(Items)
      .catch _.Error('fetchGroupUsersMissingItems err')


userItemsCount = (user)->
  nonPrivate = true
  user.inventoryLength(nonPrivate) or 0
