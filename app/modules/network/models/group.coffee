error_ = require 'lib/error'
# defining all and _recalculateAll methods
aggregateUsersIds = require '../lib/aggregate_users_ids'
groupActions = require '../lib/group_actions'
defaultCover = require('lib/urls').images.brittanystevens
{ escapeExpression } = Handlebars
Positionable = require 'modules/general/models/positionable'

module.exports = Positionable.extend
  url: app.API.groups.authentified
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

    @initMembersCollection()
    @initRequestersCollection()

    # keep internal lists updated
    @on 'list:change', @recalculateAllLists.bind(@)
    # updated collections once the debounced recalculateAllLists is done
    @on 'list:change:after', @initMembersCollection.bind(@)
    @on 'list:change:after', @initRequestersCollection.bind(@)

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

  itemsCount: -> _.sum @members.map(userItemsCount)

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
      # itemsCount isnt available for public groups
      # due to an unsolved issue with user:inventoryLength in this case
      itemsCount: if mainUserIsMember then @itemsCount() else 0
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

  matchable: ->
    [
      @get('name')
      @get('description')
    ]

userItemsCount = (user)->
  nonPrivate = true
  user.inventoryLength(nonPrivate) or 0
