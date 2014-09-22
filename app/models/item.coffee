module.exports = class Item extends Backbone.NestedModel
  url: ->
    # keeps the url built at runtime to follow revs evolution
    # which are needed to be in the url for DELETE
    @updatedUrl()

  updatedUrl: -> app.API.items.item @get('owner'), @id, @get('_rev')

  validate: (attrs, options)->
    unless attrs.title? then return "a title must be provided"

  initialize: (attrs, options)->
    _.log arguments, 'item:initialization args'
    # defaults to current user as owner
    # allowing entities to user the Item model without an owner
    owner = @get('owner')
    if not owner? then throw new Error 'an owner should be provided'

    @username = app.request('getUsernameFromId', owner)

    @setDefaults()

    itemId = @get '_id'
    pathname = "/inventory/#{itemId}"

    itemTitle = _.softEncodeURI @get('title')
    pathname += "/#{itemTitle}"  if itemTitle?

    @set 'pathname', pathname

    @profilePic = app.request('getProfilePicFromId', owner)
    @restricted = true unless @get('owner') is app.user.id

  setDefaults: ->
    attrs =
      _id: @get('_id') or @buildId()
      created: @get('created') or new Date()
      owner: @get('owner') or app.user.get('_id')
    @set attrs

  buildId: ->
    suffix = @getUri() or _.idGenerator(6)
    return @username + '/' + suffix

  getUri: ->
    entity = @get('entity')
    if _.isKnownUri(entity) then return entity
    else return

  serializeData: ->
    attrs = @toJSON()
    _.extend attrs,
      username: @username
      profilePic: @profilePic
      restricted: @restricted
      created: new Date(attrs.created).toLocaleDateString()
    return attrs

  matches: (expr) ->
    return true  if expr is null
    hasMatch = _.some @asMatchable(), (field) ->
      if field?
        return field.match(expr) isnt null
      else
        return false
    return true  if hasMatch
    false

  asMatchable: ->
    [
      @get("title")
      @get("comment")
      @get("username")
    ]