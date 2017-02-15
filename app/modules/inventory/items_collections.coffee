Items = require './collections/items'

module.exports = (app, _)->
  items = new Items

  itemsAddProxy = items.add.bind items

  attachFilteredCollection = (label, filter)->
    items[label] = new FilteredCollection items
    items[label].filterBy label, filter
    items[label].add = itemsAddProxy

  isMainUser = (model)-> model.get('owner') is app.user.id
  isFriend = (model)-> app.request 'user:isFriend', model.get('owner')
  isPublicUser = (model)-> app.request 'user:isPublicUser', model.get('owner')
  isNetworkUser = (model)-> not isMainUser(model) and not isPublicUser(model)

  attachFilteredCollection 'personal', isMainUser
  items.personal.create = items.create.bind items
  items.personal.byEntityUri = items.byEntityUri.bind items.personal
  items.personal.byEntityUris = items.byEntityUris.bind items.personal
  # used to overcome the issue with first use of isMainUser
  # while app.user.id is undefined
  app.user.once 'change', -> items.personal.refilter()

  attachFilteredCollection 'friends', isFriend

  attachFilteredCollection 'public', isPublicUser
  items.public.byEntityUris = items.byEntityUris.bind items.public

  # Includes users who made a friend request or to which a friend request was made
  attachFilteredCollection 'network', isNetworkUser
  items.network.byEntityUris = items.byEntityUris.bind items.network

  return items
