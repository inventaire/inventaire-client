module.exports = (app, _)->

  Items = new app.Collection.FriendsItems

  isMainUser = (model)-> model.get('owner') is app.user.id
  personal = new FilteredCollection(Items)
  personal.filterBy 'personal', isMainUser

  # used to overcome the issue with first use of isMainUser
  # while app.user.id is undefined
  app.user.once 'change', -> personal.refilter()

  NotMainUser = (model)-> model.get('owner') isnt app.user.id
  friends = new FilteredCollection(Items).filterBy 'friends', NotMainUser
  friends.fetchFriendItems = Items.fetchFriendItems.bind(Items)

  app.vent.on 'friends:items:ready', -> friends.fetched = true

  return _.extend Items,
    personal: personal
    friends: friends
    public: new app.Collection.Items