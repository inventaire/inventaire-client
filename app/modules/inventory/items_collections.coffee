FriendsItems = require './collections/friends_items'

module.exports = (app, _)->

  Items = new FriendsItems

  isMainUser = (model)-> model.get('owner') is app.user.id
  personal = new FilteredCollection(Items)
  personal.filterBy 'personal', isMainUser
  personal.add = Items.add.bind(Items)
  personal.create = Items.create.bind(Items)

  # used to overcome the issue with first use of isMainUser
  # while app.user.id is undefined
  app.user.once 'change', -> personal.refilter()

  isFriend = (model)-> app.request 'user:isFriend', model.get('owner')
  friends = new FilteredCollection(Items).filterBy 'friends', isFriend
  friends.fetchFriendItems = Items.fetchFriendItems.bind(Items)
  friends.add = Items.add.bind(Items)


  app.vent.once 'friends:items:ready', -> friends.fetched = true

  isPublicUser = (model)-> app.request 'user:isPublicUser', model.get('owner')
  # public is a reserved word
  publik = new FilteredCollection(Items).filterBy 'public', isPublicUser
  publik.add = Items.add.bind(Items)

  return _.extend Items,
    personal: personal
    friends: friends
    public: publik