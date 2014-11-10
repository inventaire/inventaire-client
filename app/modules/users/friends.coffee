module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->

  initialize: ->
    app.users.friends.filtered = new FilteredCollection(app.users.friends)

    app.reqres.setHandlers
      'friends:search': API.searchFriends


API =
  searchFriends: (text)->
    friends = app.users.friends.filtered
    return friends.filterByText text