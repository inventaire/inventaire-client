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
    .always ->
      app.vent.trigger 'friends:items:ready'

  initialize: ->
    @lazyFetchFriendsItems = _.debounce @fetchFriendsItems, 50