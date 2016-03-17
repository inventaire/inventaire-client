Filterable = require 'modules/general/models/filterable'

module.exports = Filterable.extend
  url: -> app.API.items.base

  validate: (attrs, options)->
    unless attrs.title? then return "a title must be provided"
    unless attrs.owner? then return "an owner must be provided"

  initialize: (attrs, options)->
    { entity, title, owner } = attrs

    unless entity?
      throw new Error "item should have an associated entity"

    @entityUri = app.request 'normalize:entity:uri', entity
    # make sure the entity model is loaded in the global app.entities collection
    # and thus accessible from a app.entities.byUri
    @waitForEntity = @reqGrab 'get:entity:model', @entityUri, 'entity'


    # created will be overriden by the server at item creation
    @set
      created: @get('created') or _.now()
      _id: @getId()

    @setPathname()

    @entityPathname = app.request 'get:entity:local:href', @entityUri, title

    @userReady = false

    @reqGrab 'get:user:model', owner, 'user'
    .then @setUserData.bind(@)
    # chain it to get access to @restricted
    .then => @waitForEntity
    .then @lookForMissingData.bind(@)

  onCreation: (serverRes)->
    # update the _id from 'new' to the server _id
    # but don't update other attributes such as transaction and visibility
    # that might have been changed since the server received the creation request
    udpate = _.pick serverRes, ['_id', '_res']
    @set udpate
    # update derivated attributes
    @setPathname()

  setUserData: ->
    { user } = @
    @username = user.get 'username'
    @authorized = user.id? and user.id is app.user.id
    @restricted = not @authorized
    @userReady = true

  # using 'new' as a temporary id to signal to the server
  # that this item should be created
  # and set an id from the db from the server response
  getId: -> @get('_id') or 'new'
  setPathname: -> @pathname = '/items/' + @id

  serializeData: ->
    attrs = @toJSON()
    _.extend attrs,
      pathname: @pathname
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
        listing = mainModel?.get 'listing'

      attrs.currentListing = app.user.listings()[listing]
      attrs.listings = app.user.listings()
      attrs.listings[listing].classes = 'selected'

    else
      # used to hide the "request button" given accessible transactions
      # are necessarly involving the main user, which should be able
      # to have several transactions ongoing with a given item
      attrs.hasActiveTransaction = @hasActiveTransaction()

    # picture may be undefined
    attrs.picture = attrs.pictures?[0]

    return attrs

  userData: ->
    if @userReady
      { user } = @
      return userData =
        username: @username
        picture: user.get 'picture'
        pathname: user.get 'pathname'
        distance: user.distanceFromMainUser

  asMatchable: ->
    [
      @get('title')
      @get('authors')
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
    @waitForEntity
    # cant be @entity.updateMetadata.bind(@entity)
    # as @entity is probably undefined yet
    .then => @entity.updateMetadata()
    .then @executeMetadataUpdate.bind(@)

  executeMetadataUpdate: ->
    app.execute 'metadata:update',
      title: @findBestTitle()
      description: @findBestDescription()?[0..500]
      image: @get('pictures')?[0]
      url: @pathname

  findBestTitle: ->
    title = @get('title')
    transaction = @get 'transaction'
    context = _.i18n "#{transaction}_personalized", {username: @username }
    return "#{title} - #{context}"

  findBestDescription: ->
    details = @get('details')
    if _.isNonEmptyString(details) then details

  # keep a copy of authors as a string on the item
  lookForMissingData: ->
    if @restricted then return
    @updateAuthor()
    @lookForPicture()

  updateAuthor: ->
    current = @get 'authors'
    @entity.getAuthorsString()
    .then (update)=>
      if _.isNonEmptyString(update) and current isnt update
        _.log [current, update], 'updateAuthor'
        @saveWhenPossible 'authors', update
    .catch _.Error('updateAuthor')

  lookForPicture: ->
    # pass if the item already has a picture
    if @get('pictures')?[0]? then return
    entityPictures = @entity.get 'pictures'
    if _.isArray(entityPictures) and entityPictures.length > 0
      @saveWhenPossible 'pictures', entityPictures

  hasActiveTransaction: ->
    # the reqres 'has:transactions:ongoing:byItemId' wont be defined
    # if the user isn't logged in
    unless app.user.loggedIn then return false
    return app.request 'has:transactions:ongoing:byItemId', @id

  saveWhenPossible: (key, value)->
    if @id is 'new'
      # the item wasn't created yet in the database
      # and updating right now would thus create a dupplicate
      _.log arguments, 'delayed item save'
      # return a promise to keep the interface consistant
      return _.preq.delay(1000).then @saveWhenPossible.bind(@, key, value)
    else
      _.log arguments, 'finally saving item'
      # wrapping the jQuery promise
      return _.preq.resolve @save(key, value)
