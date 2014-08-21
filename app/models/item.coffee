module.exports = class Item extends Backbone.Model
  # defaults:
    # entity: uri
    # version: uri
    # instance:
    #   uri: null
    #   comment: null
    #   owner: null
    #   state: null
    #   history:
    #     created: null
    #     transactions:
    #       [
    #         # date:
    #           #from: uri
    #           #transaction
    #             # type: uri
    #             # price: number
    #           #to: uri
    #       ]
  url: ->
    # keeps the url built at runtime to follow revs evolution
    # which are needed to be in the url for DELETE
    @updatedUrl()

  updatedUrl: -> app.API.items.item @get('owner'), @id, @get('_rev')

  initialize: ->
    owner = @get('owner')
    @username = app.request('getUsernameFromId', owner)
    @profilePic = app.request('getProfilePicFromId', owner)
    @restricted= true unless @get('owner') is app.user.id

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