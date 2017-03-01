Items = require 'modules/inventory/collections/items'
error_ = require 'lib/error'

mainUserItemsFetched = false
networkItemsFetched = false

fetchByIds = (requestedIds)->
  alreadyFetchedIds = app.items.models.map _.property('id')
  ids = _.difference requestedIds, alreadyFetchedIds
  if ids.length is 0 then return _.preq.resolved

  _.preq.get app.API.items.byIds({ ids })
  .then spreadData
  .catch _.ErrorRethrow('fetchByIds err')

alreadyFetchedUrisIndex = {}
# Populating app.items with the desired entities items
fetchByEntity = (uris)->
  alreadyFetchedUris = Object.keys alreadyFetchedUrisIndex
  missingUris = _.difference uris, alreadyFetchedUris
  if missingUris.length is 0
    return Promise.props _.pick(alreadyFetchedUrisIndex, uris)

  promise = _.preq.get app.API.items.byEntities({ ids: missingUris })
    .then spreadData
    .catch _.ErrorRethrow('fetchByEntity err')

  for missingUri in missingUris
    alreadyFetchedUrisIndex = promise

  return promise

fetchByUsernameAndEntity = (username, entity)->
  _.preq.get app.API.items.byUsernameAndEntity(username, entity)
  .then spreadData
  .catch _.ErrorRethrow('fetchByUsernameAndEntity err')

fetchByUserIdAndEntity = (userId, entityUri)->
  _.preq.get app.API.items.byUserAndEntity(userId, entity)
  .then spreadData
  .catch _.ErrorRethrow('fetchByUserIdAndEntity err')

# Adding the users and items to the global collections
spreadData = (data)->
  { users, items } = data
  if users? then app.execute 'users:public:add', users
  newlyAddedItemsModels = app.items.add items
  return newlyAddedItemsModels

waitForMainUserItems = null
waitForNetworkItems = null

fetchById = (id)->
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

getNetworkItems = (params)->
  app.request 'waitForNetwork'
  .then ->
    networkIds = app.users.friends.list.concat(app.relations.coGroupMembers)
    makeRequest params, 'byUsers', networkIds

getUserItems = (params)->
  userId = params.model.id
  makeRequest params, 'byUsers', [ userId ]

getGroupItems = (params)->
  makeRequest params, 'byUsers', params.model.allMembersIds(), 'group'

makeRequest = (params, endpoint, ids, filter)->
  if ids.length is 0 then return { items: [], total: 0 }
  { collection, limit, offset } = params
  _.preq.get app.API.items[endpoint]({ ids, limit, offset, filter })
  # Use tap to return the server response instead of the collection
  .tap addUsersAndItems(collection)

getNearbyItems = ->
  collection = new Items
  _.preq.get app.API.items.nearby()
  .then addUsersAndItems(collection)

getLastPublic = (params)->
  { collection, limit, offset, assertImage } = params
  _.preq.get app.API.items.lastPublic(limit, offset, assertImage)
  .then addUsersAndItems(collection)

addUsersAndItems = (collection)-> (res)->
  { items, users } = res
  # Also accepts items indexed by listings: user, network, public
  unless _.isArray items then items = _.flatten _.values(items)
  unless items?.length > 0 then throw error_.new 'no public items', 404

  app.execute 'users:public:add', users
  collection.add items
  return collection

module.exports = (app)->
  app.reqres.setHandlers
    # Fetch: make sure the items are added to the global collections
    #  => uses spreadData
    'items:fetchById': fetchById
    'items:fetchByEntity': fetchByEntity
    'items:fetchNetworkItems': fetchNetworkItems
    'items:fetchByUserIdAndEntity': fetchByUserIdAndEntity
    'items:fetchByUsernameAndEntity': fetchByUsernameAndEntity
    # Get: Fetch and return the desired models
    #  => uses addUsersAndItems
    'items:getNearbyItems': getNearbyItems
    'items:getLastPublic': getLastPublic
    'items:getNetworkItems': getNetworkItems
    'items:getUserItems': getUserItems
    'items:getGroupItems': getGroupItems
