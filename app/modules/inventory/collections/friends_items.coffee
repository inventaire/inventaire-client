Items = require './items'

module.exports = class FriendsItems extends Items
  friendsItemsToFetch: []

  fetchFriendItems: (friendModel)->
    @friendsItemsToFetch.push friendModel.id
    @lazyFetchFriendsItems()

  fetchFriendsItems: ->
    ids = @friendsItemsToFetch
    @friendsItemsToFetch = new Array
    _.preq.get app.API.users.items(ids)
    .then (items)=>
      _.log items, 'items:friends'
      items.forEach (item)=>
        itemModel = @add item
        itemModel.username = app.request 'get:username:from:userId', item.owner
    .fail _.error
    .always => @friendsReady()

  initialize: ->
    @lazyFetchFriendsItems = _.debounce @fetchFriendsItems, 50

    app.commands.setHandlers
      'friends:zero': @friendsReady.bind(@)

  friendsReady:->
    app.vent.trigger 'friends:items:ready'
    @fetched = true
