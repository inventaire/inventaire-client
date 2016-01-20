error_ = require 'lib/error'
# defining all and _recalculateAll methods
aggregateUsersIds = require '../lib/aggregate_users_ids'
groupActions = require '../lib/group_actions'
defaultCover = require('lib/urls').images.brittanystevens
{ escapeExpression } = Handlebars
Positionable = require 'modules/general/models/positionable'

module.exports = Positionable.extend
  url: app.API.groups.private
  initialize: ->
    aggregateUsersIds.call @
    _.extend @, groupActions

    { _id, name } = @toJSON()
    uriEscapedGroupName = @getUriEscapedName()
    canonical = "/groups/#{_id}"
    pathname = "#{canonical}/#{uriEscapedGroupName}"
    @set
      canonical: canonical
      pathname: pathname
      boardPathname: "/network#{pathname}"
      # non-persisted category used for convinience on client-side
      tmp: []

    @initMembersCollection()
    @initRequestersCollection()

    @on
      # keep internal lists updated
      'list:change': @recalculateAllLists.bind(@)
      # udpated collections once the debounced recalculateAllLists is done
      'list:change:after': @initMembersCollection.bind(@)
      'list:change:after': @initRequestersCollection.bind(@)

  initMembersCollection: -> @initUsersCollection 'members'
  initRequestersCollection: -> @initUsersCollection 'requested'
  initUsersCollection: (name)->
    # remove all users
    # to re-add all of them
    # while keeping the same object to avoid breaking references
    @[name] or= new Backbone.Collection
    @[name].remove @[name].models
    Name = _.capitaliseFirstLetter name
    ids = @["all#{Name}Ids"]()
    for userId in ids
      @fetchUser @[name], userId

  fetchUser: (collection, userId)->
    app.request 'get:group:user:model', userId
    .then collection.add.bind(collection)
    .catch _.Error('fetchMembers')

  getUserIds: (category)->
    @get(category).map _.property('user')

  membersCount: -> @allMembersIds().length
  requestsCount: ->
    # only used to count groups notifications
    # which only concern group admins
    if @mainUserIsAdmin() then @requested.length
    else 0

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

    if attrs.position?
      # overriding the position latLng array
      attrs.position =
        lat: attrs.position[0]
        lng: attrs.position[1]

    _.extend attrs,
      publicDataOnly: @publicDataOnly
      membersCount: @membersCount()
      # itemsCount isnt available for public groups
      # due to an unsolved issue with user:inventoryLength in this case
      itemsCount: @itemsCount()  unless @publicDataOnly
      mainUserIsAdmin: @mainUserIsAdmin()
      mainUserIsMember: @mainUserIsMember()
      hasPosition: @hasPosition()

  userStatus: (user)->
    { id } = user
    if id in @allMembersIds() then return 'member'
    else if id in @allInvitedIds() then return 'invited'
    else if id in @allRequestedIds() then return 'requested'
    else 'none'

  userIsAdmin: (userId)->
    return userId in @allAdminsIds()

  mainUserStatus: -> @userStatus app.user
  mainUserIsAdmin: -> app.user.id in @allAdminsIds()
  mainUserIsMember: -> app.user.id in @allMembersIds()
  mainUserIsInvited: -> app.user.id in @allInvitedIds()

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
    groupNonFriendsUsersIds = app.request 'get:non:friends:ids', @allMembersIds()
    _.log groupNonFriendsUsersIds, 'groupNonFriendsUsersIds'
    if groupNonFriendsUsersIds.length > 0
      _.preq.get app.API.users.items(groupNonFriendsUsersIds)
      .then _.Log('groupNonFriendsUsers items')
      .then Items.add.bind(Items)
      .catch _.Error('fetchGroupUsersMissingItems err')

  getEscapedName: -> escapeExpression @get('name')
  getUriEscapedName: -> encodeURIComponent @get('name')

  userCanLeave: ->
    unless @mainUserIsAdmin() then return true
    mainUserIsTheOnlyAdmin = @allAdminsIds().length is 1
    thereAreOtherMembers = @allMembersStrictIds().length > 0
    if mainUserIsTheOnlyAdmin and thereAreOtherMembers then false
    else true

  userIsLastUser: -> @allMembersIds().length is 1

  updateMetadata: ->
    app.execute 'metadata:update',
      title: @get 'name'
      description: @getDescription()
      image: @getCover()
      url: @get 'canonical'

  getDescription: ->
    desc = @get 'description'
    if _.isNonEmptyString desc then desc
    else _.i18n 'group_default_description', {groupName: @get('name')}

  getCover: -> @get('picture') or defaultCover

  asMatchable: ->
    [
      @get('name')
      @get('description')
    ]

userItemsCount = (user)->
  nonPrivate = true
  user.inventoryLength(nonPrivate) or 0
