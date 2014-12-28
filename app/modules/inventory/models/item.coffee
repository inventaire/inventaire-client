Filterable = require 'modules/general/models/filterable'

module.exports = class Item extends Filterable
  url: ->
    # keeps the url built at runtime to follow revs evolution
    # which are needed to be in the url for DELETE
    @updatedUrl()

  updatedUrl: -> app.API.items.item @get('owner'), @id, @get('_rev')

  validate: (attrs, options)->
    unless attrs.title? then return "a title must be provided"
    unless attrs.owner? then return "a owner must be provided"

  initialize: (attrs, options)->
    # RECIPE:
      # suffix = entityUri or random(6)
      # _id = owner:suffix
      # pathname = username:suffix
    # this allows entityUri to be used in pathname without
    # letting them be the DB's reference _id with of
    # collisions everytime two people have an instance
    # of the same entity object
    if attrs.entity? then @getEntityModel(attrs.entity)

    attrs.owner = @get('owner')
    attrs.suffix = @getSuffix()
    attrs.created = @get('created') or _.now()
    attrs._id = @getId(attrs)

    @set attrs

    @username = app.request 'get:username:from:userId', attrs.owner
    @profilePic = app.request 'get:profilePic:from:userId', attrs.owner
    @pathname = @buildPathname(attrs)
    @restricted = attrs.owner isnt app.user.id

    if attrs.entity?
      @entityPathname = "/entity/#{attrs.entity}/#{attrs.title}"

    if @get('notes')? and @get('owner') isnt app.user.id
      console.error @username, @get('notes'), 'I can see others notes!!!!'

  getSuffix: ->
    if @get('suffix') then return @get('suffix')
    else
      entity = @get('entity')
      if _.hasKnownUriDomain(entity) then return entity
      else _.idGenerator(6)

  getId: (attrs)->
    if @get('_id') then return @get('_id')
    else return "#{attrs.owner}:#{attrs.suffix}:#{attrs.created}"

  buildPathname: (attrs)->
    if @username? and attrs.suffix?
      pathname = "/inventory/#{@username}/#{attrs.suffix}"
      title = _.softEncodeURI @get('title')
      pathname += "/#{title}"  if title?
      return pathname
    else return

  serializeData: ->
    attrs = @toJSON()
    _.extend attrs,
      username: @username
      pathname: @pathname
      entityPathname: @entityPathname
      profilePic: @profilePic
      restricted: @restricted
      created: moment(attrs.created).fromNow()

    attrs.currentTransaction = Items.transactions[attrs.transaction]
    unless attrs.restricted
      attrs.transactions = Items.transactions
      attrs.currentListing = app.user.listings[attrs.listing]
      attrs.listings = app.user.listings
      attrs.uiId = _.idGenerator(4, true)

    if @entity? then attrs.entity = @entity.toJSON()

    unless _.isEmpty attrs.pictures
      attrs.picture = attrs.pictures[0]
    else attrs.picture = _.placeholder()

    return attrs

  asMatchable: ->
    [
      @get('title')
      @get('username')
      @get('comment')
      @get('notes')
      @get('entity')
    ]

  getEntityModel: (uri)->
    app.request 'get:entity:model', uri
    .then (entityModel)=> @entity = entityModel
    .fail (err)-> console.error 'get:entity:model fail', err