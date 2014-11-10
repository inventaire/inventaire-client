module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    app.users.friends.filtered = new FilteredCollection(app.users.friends)

    app.reqres.setHandlers
      'friends:search': API.searchFriends


API =
  searchFriends: (text)->
    friends = app.users.friends.filtered
    friends.resetFilters()
    filterExpr = new RegExp text, "i"
    friends.filterBy 'text', (model)-> model.matches filterExpr
    return friends