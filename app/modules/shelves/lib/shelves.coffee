error_ = require 'lib/error'

module.exports = shelves_ =
  getById: (id)->
    _.preq.get app.API.shelves.byIds(id)
    .then getShelf

  createShelf: (params)->
    _.preq.post app.API.shelves.create, params
    .get('shelf')

  updateShelf: (params)->
    _.preq.post app.API.shelves.update, params
    .get 'shelf'

  deleteShelf: (params)->
    _.preq.post app.API.shelves.delete, params

  removeItems: (model, items)->
    { id } = model
    items = _.forceArray items
    itemsIds = items.map (item)->
      item.removeShelf id
      item.get('_id')
    model.set 'isInShelf', false
    return shelfActionReq id, itemsIds, 'removeItems'

  addItems: (model, items)->
    { id } = model
    items = _.forceArray items
    itemsIds = items.map (item)->
      item.createShelf id
      item.get('_id')
    model.set 'isInShelf', true
    return shelfActionReq id, itemsIds, 'addItems'

  getShelvesByOwner: (userId)->
    unless userId then userId = app.user.id
    _.preq.get app.API.shelves.byOwners(userId)
    .get 'shelves'
    .then _.values

  countShelves: (userId)->
    _.preq.get app.API.shelves.byOwners(userId)
    .get 'shelves'
    .then (shelves)-> Object.keys(shelves).length

shelfActionReq = (id, itemsIds, action)->
  _.preq.post app.API.shelves[action], { id, items: itemsIds }
  .then getShelf

getShelf = (res)->
  shelvesObj = res.shelves
  Object.values(shelvesObj)[0]
