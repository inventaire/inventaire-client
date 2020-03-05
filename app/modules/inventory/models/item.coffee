Filterable = require 'modules/general/models/filterable'
error_ = require 'lib/error'
saveOmitAttributes = require 'lib/save_omit_attributes'
{ factory:transactionsDataFactory } = require '../lib/transactions_data'
{ buildPath } = require 'lib/location'

module.exports = Filterable.extend
  initialize: (attrs, options)->
    @testPrivateAttributes()

    { entity, owner } = attrs

    @mainUserIsOwner = owner is app.user.id

    unless _.isEntityUri entity
      throw error_.new "invalid entity URI: #{entity}", attrs

    @entityUri = entity

    @setPathname()

    @entityPathname = app.request 'get:entity:local:href', @entityUri

    @initUser owner

  initUser: (owner)->
    # Check the main user early, so that we can access authorized data directly on first render
    if @mainUserIsOwner
      @user = app.user
      @userReady = true
      @waitForUser = Promise.resolve()
      @setUserData()
    else
      @userReady = false
      @waitForUser = @reqGrab 'get:user:model', owner, 'user'
        .then @setUserData.bind(@)

  # Checking that attributes privacy is as expected
  testPrivateAttributes: ->
    hasPrivateAttributes = @get('listing')?
    if @get('owner') is app.user.id
      unless hasPrivateAttributes
        error_.report 'item missing private attributes', @
    else
      if hasPrivateAttributes
        error_.report 'item has private attributes', @

  grabEntity: ->
    @waitForEntity or= @reqGrab 'get:entity:model', @entityUri, 'entity'
    return @waitForEntity

  grabWorks: ->
    if @waitForWorks? then return @waitForWorks

    return @waitForWorks = @grabEntity()
      .then (entity)->
        if entity.type is 'work' then return [ entity ]
        else return entity.waitForWorks
      .then (works)=> @grab 'works', works

  setUserData: ->
    { user } = @
    @username = user.get 'username'
    @authorized = user.id? and user.id is app.user.id
    @restricted = not @authorized
    @userReady = true
    @trigger 'user:ready'

  setPathname: -> @set 'pathname', '/items/' + @id

  serializeData: ->
    attrs = @toJSON()

    _.extend attrs,
      title: @get('snapshot.entity:title')
      personalizedTitle: @findBestTitle()
      subtitle: @get('snapshot.entity:subtitle')
      entityPathname: @entityPathname
      restricted: @restricted
      userReady: @userReady
      mainUserIsOwner: @mainUserIsOwner
      user: @userData()
      isPrivate: attrs.listing is 'private'

    # @entity will be defined only if @grabEntity was called
    if @entity?
      attrs.entityData = @entity.toJSON()
      { type } = @entity
      attrs.entityType = type
      Type = _.capitalise type
      attrs["entityIs#{Type}"] = true

    { transaction } = attrs
    transacs = transactionsDataFactory()
    attrs.currentTransaction = transacs[transaction]
    attrs[transaction] = true

    if @authorized
      attrs.transactions = transacs
      attrs.transactions[transaction].classes = 'selected'

      { listing } = attrs
      attrs.currentListing = app.user.listings()[listing]
      attrs.listings = app.user.listings()
      attrs.listings[listing].classes = 'selected'

    else
      # used to hide the "request button" given accessible transactions
      # are necessarly involving the main user, which should be able
      # to have several transactions ongoing with a given item
      attrs.hasActiveTransaction = @hasActiveTransaction()

    # picture may be undefined
    attrs.picture = @getPicture()
    attrs.authors = @get 'snapshot.entity:authors'
    attrs.series = @get 'snapshot.entity:series'
    attrs.ordinal = @get 'snapshot.entity:ordinal'

    return attrs

  userData: ->
    if @userReady
      { user } = @
      return userData =
        username: @username
        picture: user.get 'picture'
        pathname: user.get 'pathname'
        distance: user.distanceFromMainUser

  matchable: ->
    [
      @get('snapshot.entity:title')
      @get('snapshot.entity:authors')
      @get('snapshot.entity:series')
      @username
      @get('details')
      @get('notes')
      @get('entity')
    ]

  # passing id and rev as query paramaters
  destroy: ->
    # reproduce the behavior from the default Bacbkone::destroy
    @trigger 'destroy', @, @collection
    _.preq.post app.API.items.deleteByIds, { ids: [ @id ] }
    .tap => @isDestroyed = true

  # to be called by a view onShow:
  # updates the document with the item data
  updateMetadata: ->
    # start by adding the entity's metadata
    # and then override by the data available on the item
    Promise.all [
      # wait for every model the item model depends on
      @waitForUser
      @grabEntity()
    ]
    # /!\ cant be replaced by @entity.updateMetadata.bind(@entity)
    # as @entity is probably undefined yet
    .then => @entity.updateMetadata()
    .then @executeMetadataUpdate.bind(@)

  executeMetadataUpdate: ->
    return Promise.props
      title: @findBestTitle()
      description: @findBestDescription()?[0..500]
      image: @getPicture()
      url: @get 'pathname'

  getPicture: -> @get('pictures')?[0] or @get('snapshot.entity:image')

  findBestTitle: ->
    title = @get('snapshot.entity:title')
    transaction = @get 'transaction'
    context = _.i18n "#{transaction}_personalized", { @username }
    return "#{title} - #{context}"

  findBestDescription: ->
    details = @get 'details'
    if _.isNonEmptyString details then details
    else @entity.findBestDescription()

  hasActiveTransaction: ->
    # the reqres 'has:transactions:ongoing:byItemId' wont be defined
    # if the user isn't logged in
    unless app.user.loggedIn then return false
    return app.request 'has:transactions:ongoing:byItemId', @id

  # Omit pathname on save, as is expected to be found in the model attributes
  # in the client, but is an invalid attribute from the server point of view
  save: saveOmitAttributes 'pathname'

  # Gather save actions
  lazySave: (key, value)->
    # Created a debounced save function if non was created before
    @_lazySave or= _.debounce @save.bind(@), 200
    # Set any passed
    @set key, value
    # Trigger it
    @_lazySave()

  getCoords: -> @user?.getCoords()

  hasPosition: -> @user?.has('position')

  addShelf: (shelfId)->
    unless @get 'shelves' then @set 'shelves', []
    shelvesIds = @get 'shelves'
    if shelfId in shelvesIds then return
    shelvesIds.push shelfId
    return _.preq.post app.API.shelves.addItems, { id: shelfId, items: [ @get '_id' ] }

  deleteShelf: (shelfId)->
    shelvesIds = @get 'shelves'
    if shelfId not in shelvesIds then return
    shelvesIds = _.without shelvesIds, shelfId
    @set 'shelves', shelvesIds
    return _.preq.post app.API.shelves.removeItems, { id: shelfId, items: [ @get '_id' ] }

  isInShelf: (shelfId)->
    shelvesIds = @get 'shelves'
    unless shelvesIds then return false
    return shelfId in shelvesIds
