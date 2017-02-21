Items = require './collections/items'

module.exports = (app, _)->
  items = new Items

  itemsAddProxy = items.add.bind items

  attachFilteredCollection = (label, filter)->
    items[label] = new FilteredCollection items
    items[label].filterBy label, filter
    items[label].add = itemsAddProxy

  isMainUser = (model)-> model.get('owner') is app.user.id
  isNetworkUser = (model)->
    networkIds = app.users.friends.list.concat(app.relations.coGroupMembers)
    return model.get('owner') in networkIds
  isPublicUser = (model)-> app.request 'user:isPublicUser', model.get('owner')

  attachFilteredCollection 'personal', isMainUser
  items.personal.create = items.create.bind items
  items.personal.byEntityUri = items.byEntityUri.bind items.personal
  items.personal.byEntityUris = items.byEntityUris.bind items.personal
  # used to overcome the issue with first use of isMainUser
  # while app.user.id is undefined
  app.user.once 'change', -> items.personal.refilter()

  # Includes users who made a friend request or to which a friend request was made
  attachFilteredCollection 'network', isNetworkUser
  items.network.byEntityUris = items.byEntityUris.bind items.network

  attachFilteredCollection 'public', isPublicUser
  items.public.byEntityUris = items.byEntityUris.bind items.public

  return items
