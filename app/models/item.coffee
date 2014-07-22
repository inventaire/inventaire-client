module.exports = class Item extends Backbone.Model
  # defaults:
    # entity:
    #   uri: null
    #   title: null
    #   P31: null
    # version:
    #   uri: null
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
    if (rev = @get '_rev')?
      'api/items/' + @id + '/' + rev
    else
      'api/items/' + @id

  initialize: ->
    @set 'username', app.request('getUsernameFromId', @get('owner'))
    @set('restricted', true) unless @get('owner') is app.user.id

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