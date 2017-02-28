# Fetch: make sure the items are added to the global collections
# Get: Fetch and return the desired models

Items = require 'modules/inventory/collections/items'
error_ = require 'lib/error'

mainUserItemsFetched = false
networkItemsFetched = false

fetchByIds = (requestedIds)->
  alreadyFetchedIds = app.items.models.map _.property('id')
  ids = _.difference requestedIds, alreadyFetchedIds
  if ids.length is 0 then return _.preq.resolved

  _.preq.get app.API.items.byIds({ ids })
  .then _.Log("items by ids: #{ids}")
  .then spreadData
  .catch _.ErrorRethrow('fetchByIds err')

alreadyFetchedUris = []
fetchByEntity = (uris)->
  uris = _.difference uris, alreadyFetchedUris
  if uris.length is 0 then return _.preq.resolved

  alreadyFetchedUris = alreadyFetchedUris.concat uris

  _.preq.get app.API.items.byEntities({ ids: uris })
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
  newlyAddedItemsModels = app.items.add items
  return newlyAddedItemsModels

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

nearby = ->
  collection = new Items
  _.preq.get app.API.items.nearby()
  .then _.Log('showItemsNearby res')
  .then addUsersAndItems(collection)

lastPublic = (params)->
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
    'items:getById': getById
    'fetchNetworkItems': fetchNetworkItems
    'items:getByUsernameAndEntity': getByUsernameAndEntity
    'items:nearby': nearby
    'items:lastPublic': lastPublic
    'items:getNetworkItems': getNetworkItems
    'items:getUserItems': getUserItems
    'items:getGroupItems': getGroupItems
