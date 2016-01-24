Items = require 'modules/inventory/collections/items'
ItemsList = require 'modules/inventory/views/items_list'

module.exports = (region)->
  _.preq.get app.API.items.lastPublicItems()
  .catch _.preq.catch404
  .then displayPublicItems.bind(null, region)

displayPublicItems = (region, res)->
  collection = new Items
  addUsersAndItems collection, res

  region.show new ItemsList
    collection: collection
    fetchMore: FetchMore collection

FetchMore = (collection)->
  fetchMore = ->
    offset = collection.length
    _.preq.get app.API.items.lastPublicItems(offset)
    .then addUsersAndItems.bind(null, collection)

  return _.debounce fetchMore, 2000, true


addUsersAndItems = (collection, res)->
  { items, users } = res
  unless items?.length > 0
    throw new Error 'no public items'

  app.execute 'users:public:add', users

  collection.add items
  return