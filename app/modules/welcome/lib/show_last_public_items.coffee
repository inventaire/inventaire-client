Items = require 'modules/inventory/collections/items'
ItemsList = require 'modules/inventory/views/items_list'

module.exports = (region)->
  _.preq.get app.API.items.lastPublicItems
  .catch _.preq.catch404
  .then displayPublicItems.bind(null, region)

displayPublicItems = (region, res)->
  unless res?.items?.length > 0
    throw new Error 'no public items'

  app.execute 'users:public:add', res.users

  region.show new ItemsList
    collection: new Items res.items
