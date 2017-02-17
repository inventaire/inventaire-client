# Fetch: make sure the items are added to the global collections
# Get: Fetch and return the desired models

Items = require 'modules/inventory/collections/items'

mainUserItemsFetched = false
networkItemsFetched = false

fetchByIds = (requestedIds)->
  alreadyFetchedIds = app.items.models.map _.property('id')
  ids = _.difference requestedIds, alreadyFetchedIds
  if ids.length is 0 then return _.preq.resolved

  _.preq.get app.API.items.byIds(ids)
  .then _.Log("items by ids: #{ids}")
  .then spreadData
  .catch _.ErrorRethrow('fetchByIds err')

alreadyFetchedUsers = []
fetchByUsers = (usersIds)->
  usersIds = _.difference usersIds, alreadyFetchedUsers
  if usersIds.length is 0 then return _.preq.resolved

  alreadyFetchedUsers = alreadyFetchedUsers.concat usersIds
  _.preq.get app.API.items.byUsers(usersIds)
  .then _.Log("items by users: #{usersIds}")
  .then spreadData
  .catch _.ErrorRethrow('fetchByUsers err')

alreadyFetchedUris = []
fetchByEntity = (uris)->
  uris = _.difference uris, alreadyFetchedUris
  if uris.length is 0 then return _.preq.resolved

  alreadyFetchedUris = alreadyFetchedUris.concat uris

  fetchPublicItemsOnly = mainUserItemsFetched and networkItemsFetched
  _.preq.get app.API.items.byEntities(uris, fetchPublicItemsOnly)
  .then _.Log("items by entity: #{uris}")
  .then spreadData
  .catch _.ErrorRethrow('fetchByEntity err')

# TODO: check if the username can be found among the already fetched users
# and if her items where already fetched
getByUsernameAndEntity = (username, entity)->
  _.preq.get app.API.items.byUsernameAndEntity(username, entity)
  .then _.Log("items by username and entity: #{username}/#{entity}")
  .then spreadData
  .catch _.ErrorRethrow('getByUsernameAndEntity err')

# Adding the users and items to the global collections
spreadData = (data)->
  { users, items } = data
  if users? then app.execute 'users:public:add', users

  newlyAddedItemsModels = []

  addItems = (resName, collectionName)->
    if items[resName]?.length > 0
      newlyAddedItemsModels.push app.items[collectionName].add(items[resName])

  addItems 'user', 'personal'
  addItems 'network', 'network'
  addItems 'public', 'public'

  return _.flatten newlyAddedItemsModels

waitForMainUserItems = null
waitForNetworkItems = null

getById = (id)->
  fetchByIds [ id ]
  .then -> app.items.byId id
  .catch _.ErrorRethrow('findItemById err (maybe the item was deleted or its visibility changed?)')

fetchNetworkItems = ->
  waitForNetworkItems or= app.request 'waitForNetwork'
    .then ->
      networkIds = app.users.friends.list.concat(app.relations.coGroupMembers)
      # Include main user
      networkIds.push app.user.id
      fetchByUsers networkIds
    .tap ->
      mainUserItemsFetched = true
      networkItemsFetched = true

  return waitForNetworkItems

nearby = ->
  collection = new Items
  _.preq.get app.API.users.publicItemsNearby()
  .then _.Log('showItemsNearby res')
  .then addUsersAndItems(collection)

lastPublic = (collection, limit, offset, assertImage)->
  _.preq.get app.API.items.lastPublic(limit, offset, assertImage)
  .then addUsersAndItems(collection)

addUsersAndItems = (collection)-> (res)->
  { items, users } = res
  unless items?.length > 0
    err = new Error 'no public items'
    err.status = 404
    throw err

  app.execute 'users:public:add', users
  collection.add items
  return collection

module.exports = (app)->
  app.reqres.setHandlers
    'items:getById': getById
    'fetchNetworkItems': fetchNetworkItems
    'items:fetchByUsers': fetchByUsers
    'items:getByUsernameAndEntity': getByUsernameAndEntity
    'items:nearby': nearby
    'items:lastPublic': lastPublic
