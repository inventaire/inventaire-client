module.exports = class Item extends Backbone.NestedModel
  url: ->
    # keeps the url built at runtime to follow revs evolution
    # which are needed to be in the url for DELETE
    @updatedUrl()

  updatedUrl: -> app.API.items.item @get('owner'), @id, @get('_rev')

  validate: (attrs, options)->
    unless attrs.title? then return "a title must be provided"

  setDefaults: ->
    attrs =
      _id: @get('_id') || _.idGenerator(6)
      created: @get('created') || new Date()
      owner: @get('owner') || app.user.get('_id')
    @set attrs


  initialize: (attrs, options)->
    @setDefaults()

    ownerId = @get 'owner'
    @username = app.request('getUsernameFromId', ownerId)
    itemId = @get '_id'
    pathname = "/i/#{@username}/#{itemId}"

    itemTitle = _.softEncodeURI @get('title')
    pathname += "/#{itemTitle}"  if itemTitle?

    @set 'pathname', pathname

    @profilePic = app.request('getProfilePicFromId', ownerId)
    @restricted = true unless @get('owner') is app.user.id

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