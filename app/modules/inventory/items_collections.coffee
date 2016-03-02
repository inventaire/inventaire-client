FriendsItems = require './collections/friends_items'

module.exports = (app, _)->

  items = new FriendsItems

  isMainUser = (model)-> model.get('owner') is app.user.id
  personal = new FilteredCollection(items)
  personal.filterBy 'personal', isMainUser
  personal.add = items.add.bind(items)
  personal.create = items.create.bind(items)
  personal.byEntityUri = items.byEntityUri.bind(personal)

  # used to overcome the issue with first use of isMainUser
  # while app.user.id is undefined
  app.user.once 'change', -> personal.refilter()

  itemsAddProxy = items.add.bind(items)

  isFriend = (model)-> app.request 'user:isFriend', model.get('owner')
  friends = new FilteredCollection(items).filterBy 'friends', isFriend
  friends.fetchFriendItems = items.fetchFriendItems.bind(items)
  friends.add = itemsAddProxy

  app.vent.once 'friends:items:ready', -> friends.fetched = true

  isPublicUser = (model)-> app.request 'user:isPublicUser', model.get('owner')
  # public is a reserved word
  publik = new FilteredCollection(items).filterBy 'public', isPublicUser
  publik.add = itemsAddProxy

  isntPublicUser = (model)-> not isPublicUser(model)
  network = new FilteredCollection(items).filterBy 'network', isntPublicUser
  network.add = itemsAddProxy

  return _.extend items,
    personal: personal
    friends: friends
    public: publik
    network: network
