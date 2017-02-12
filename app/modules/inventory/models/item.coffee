Filterable = require 'modules/general/models/filterable'
error_ = require 'lib/error'
updateSnapshotData = require '../lib/update_snapshot_data.coffee'

module.exports = Filterable.extend
  url: -> app.API.items.authentified

  validate: (attrs, options)->
    unless attrs.title? then return "a title must be provided"
    unless attrs.owner? then return "an owner must be provided"

  initialize: (attrs, options)->
    { entity, title, owner } = attrs

    # replace title with snapshot.title if simply taken from the entity
    # so that it stays in sync

    unless _.isEntityUri entity
      throw error_.new "invalid entity URI: #{entity}", attrs

    @entityUri = entity

    # created will be overriden by the server at item creation
    @set
      created: @get('created') or Date.now()
      _id: @getId()

    @setPathname()

    @entityPathname = app.request 'get:entity:local:href', @entityUri

    @userReady = false

    @waitForUser = @reqGrab 'get:user:model', owner, 'user'
      .then @setUserData.bind(@)

    @waitForUser.then updateSnapshotData.bind(@)

  grabEntity: ->
    @waitForEntity or= @reqGrab 'get:entity:model', @entityUri, 'entity'
    return @waitForEntity

  onCreation: (serverRes)->
    # update the _id from 'new' to the server _id
    # but don't update other attributes such as transaction and visibility
    # that might have been changed since the server received the creation request
    update = _.pick serverRes, ['_id', '_res']
    @set update
    # update derivated attributes
    @setPathname()

  setUserData: ->
    { user } = @
    @username = user.get 'username'
    @authorized = user.id? and user.id is app.user.id
    @restricted = not @authorized
    @userReady = true
    @trigger 'user:ready'

  # using 'new' as a temporary id to signal to the server
  # that this item should be created
  # and set an id from the db from the server response
  getId: -> @get('_id') or 'new'
  setPathname: -> @pathname = '/items/' + @id

  serializeData: ->
    attrs = @toJSON()
    _.extend attrs,
      pathname: @pathname
      # @entity will be defined only if @grabEntity was called
      entityData: @entity?.toJSON()
      entityPathname: @entityPathname
      restricted: @restricted
      userReady: @userReady
      user: @userData()

    attrs.cid = @cid

    { transaction } = attrs
    transacs = app.items.transactions()
    attrs.currentTransaction = transacs[transaction]
    attrs[transaction] = true

    if @authorized
      attrs.transactions = transacs
      attrs.transactions[transaction].classes = 'selected'

      { listing } = attrs
      unless listing?
        # main user item fetched from a public API
        # requires to borrow its listing to the private item
        mainModel = app.request 'get:item:model:sync', attrs._id
        # in the undesired case, but known issue, where the listing
        # is undefined, default to private
        listing = mainModel?.get('listing') or 'private'

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
    attrs.authors = @get('snapshot.entity:authors')

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
      @get('title')
      @get('snapshot.entity:authors')
      @username
      @get('details')
      @get('notes')
      @get('entity')
    ]

  # passing id and rev as query paramaters
  destroy: ->
    # reproduce the behavior from the default Bacbkone::destroy
    @trigger 'destroy', @, @collection
    url = _.buildPath @url(),
      id: @id
      # TODO: rev isn't required anymore
      # this might make possible to use the default Backbone behavior
      rev: @get('_rev')
    return _.preq.delete url

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
    app.execute 'metadata:update',
      title: @findBestTitle()
      description: @findBestDescription()?[0..500]
      image: @getPicture()
      url: @pathname

  getPicture: -> @get('pictures')?[0] or @get('snapshot.entity:image')

  findBestTitle: ->
    title = @get('title')
    transaction = @get 'transaction'
    context = _.i18n "#{transaction}_personalized", {username: @username }
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

  # Gather save actions
  lazySave: (key, value)->
    # Created a debounced save function if non was created before
    @_lazySave or= _.debounce @save.bind(@), 200
    # Set any passed
    @set key, value
    # Trigger it
    @_lazySave()
