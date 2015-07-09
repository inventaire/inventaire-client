Items = require './items'

module.exports = Items.extend
  friendsItemsToFetch: []

  fetchFriendItems: (friendModel)->
    @friendsItemsToFetch.push friendModel.id
    @lazyFetchFriendsItems()

  fetchFriendsItems: ->
    ids = @friendsItemsToFetch
    @friendsItemsToFetch = new Array
    _.preq.get app.API.users.items(ids)
    .then @add.bind(@)
    .always @friendsReady.bind(@)
    .catch _.Error('fetchFriendsItems err')

  initialize: ->
    @lazyFetchFriendsItems = _.debounce @fetchFriendsItems, 50

    app.commands.setHandlers
      'friends:zero': @friendsReady.bind(@)

    @on 'add', @updateCounter.bind(@, 1)
    @on 'remove', @updateCounter.bind(@, -1)

  friendsReady:->
    app.vent.trigger 'friends:items:ready'
    @fetched = true

  inventoryLength: {}

  updateCounter: (operation,  item)->
    owner = item.get('owner')
    if owner?
      counter = @inventoryLength[owner] or= 0
      counter += operation
      @inventoryLength[owner] = counter
      app.vent.trigger "inventory:#{owner}:change", counter
