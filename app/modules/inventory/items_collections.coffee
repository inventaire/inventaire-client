FriendsItems = require './collections/friends_items'

module.exports = (app, _)->
  items = new FriendsItems

  itemsAddProxy = items.add.bind items

  attachFilteredCollection = (label, filter)->
    items[label] = new FilteredCollection items
    items[label].filterBy label, filter
    items[label].add = itemsAddProxy

  isMainUser = (model)-> model.get('owner') is app.user.id
  isFriend = (model)-> app.request 'user:isFriend', model.get('owner')
  isPublicUser = (model)-> app.request 'user:isPublicUser', model.get('owner')
  isntPublicUser = (model)-> not isPublicUser(model)

  attachFilteredCollection 'personal', isMainUser
  items.personal.create = items.create.bind items
  items.personal.byEntityUri = items.byEntityUri.bind items.personal
  # used to overcome the issue with first use of isMainUser
  # while app.user.id is undefined
  app.user.once 'change', -> items.personal.refilter()

  attachFilteredCollection 'friends', isFriend

  attachFilteredCollection 'public', isPublicUser
  items.public.byEntityUris = items.byEntityUris.bind items.public

  attachFilteredCollection 'network', isntPublicUser
  items.network.byEntityUris = items.byEntityUris.bind items.network

  return items
