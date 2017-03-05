error_ = require 'lib/error'
# defining all and _recalculateAll methods
aggregateUsersIds = require '../lib/aggregate_users_ids'
groupActions = require '../lib/group_actions'
defaultCover = require('lib/urls').images.brittanystevens
{ escapeExpression } = Handlebars
Positionable = require 'modules/general/models/positionable'

module.exports = Positionable.extend
  url: app.API.groups.base
  initialize: ->
    aggregateUsersIds.call @
    _.extend @, groupActions

    { _id, name } = @toJSON()
    canonical = pathname = "/groups/#{_id}"
    @set
      canonical: canonical
      pathname: pathname
      boardPathname: "/network#{pathname}"
      # non-persisted category used for convinience on client-side
      tmp: []

    @calculateHighlightScore()

  beforeShow:->
    # All the actions to run once before showing any view displaying
    # deep groups data (with statistics, members list, etc), but that can
    # be spared otherwise
    if @_beforeShowCalledOnce then return @waitForData
    @_beforeShowCalledOnce = true

    @initMembersCollection()
    @initRequestersCollection()

    @waitForData = Promise.all [
      @waitForMembers
      @waitForRequested
    ]

    # keep internal lists updated
    @on 'list:change', @recalculateAllLists.bind(@)
    # updated collections once the debounced recalculateAllLists is done
    @on 'list:change:after', @initMembersCollection.bind(@)
    @on 'list:change:after', @initRequestersCollection.bind(@)

    return @waitForData

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
    @["waitFor#{Name}"] = @fetchUsers @[name], ids

  fetchUsers: (collection, userIds)->
    app.request 'get:group:users:models', userIds
    .then collection.add.bind(collection)
    .catch _.Error('fetchMembers')

  getUsersIds: (category)->
    @get(category).map _.property('user')

  membersCount: -> @allMembersIds().length
  requestsCount: ->
    # only used to count groups notifications
    # which only concern group admins
    if @mainUserIsAdmin() then @get('requested').length
    else 0

  itemsCount: -> if @members? then _.sum @members.map(userItemsCount)

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

    mainUserIsMember = @mainUserIsMember()

    _.extend attrs,
      membersCount: @membersCount()
      itemsCount: @itemsCount()
      mainUserIsAdmin: @mainUserIsAdmin()
      mainUserIsMember: mainUserIsMember
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

  userCanLeave: ->
    unless @mainUserIsAdmin() then return true
    mainUserIsTheOnlyAdmin = @allAdminsIds().length is 1
    thereAreOtherMembers = @allMembersStrictIds().length > 0
    if mainUserIsTheOnlyAdmin and thereAreOtherMembers then false
    else true

  userIsLastUser: -> @allMembersIds().length is 1

  updateMetadata: ->
    title: @get 'name'
    description: @getDescription()
    image: @getCover()
    url: @get 'canonical'
    rss: @getRss()

  getDescription: ->
    desc = @get 'description'
    if _.isNonEmptyString desc then desc
    else _.i18n 'group_default_description', { groupName: @get('name') }

  getCover: -> @get('picture') or defaultCover

  getRss: -> app.API.feeds 'group', @id

  matchable: ->
    [
      @get('name')
      @get('description')
    ]

  # Should only rely on data available without having to fetch users models
  calculateHighlightScore: ->
    adminFactor = if @mainUserIsAdmin() then 20 else 0
    membersFactor = @membersCount()
    randomFactor = Math.random() * 20
    ageInDays = _.daysAgo @get('created')
    # Highlight the group in its early days
    ageFactor = 50 / (1 + ageInDays)
    total = adminFactor + membersFactor + randomFactor + ageFactor
    # Inverting to get the highest scores first
    @set 'highlightScore', -total

  boostHighlightScore: ->
    highestScore = @collection.models[0].get 'highlightScore'
    @set 'highlightScore', highestScore*2
    @collection.sort()

userItemsCount = (user)->
  nonPrivate = true
  user.inventoryLength(nonPrivate) or 0
