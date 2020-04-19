error_ = require 'lib/error'

module.exports = shelf_ =
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
    itemsIds = items.map (item)->
      item.removeShelf id
      item.get('_id')
    shelfActionReq id, itemsIds, 'removeItems'
    model.set 'isInShelf', false

  addItems: (model, items)->
    { id } = model
    itemsIds = items.map (item)->
      item.addShelf id
      item.get('_id')
    shelfActionReq id, itemsIds, 'addItems'
    model.set 'isInShelf', true

  getShelvesByOwner: (userId)->
    unless userId then userId = app.user.id
    _.preq.get app.API.shelves.byOwners(userId)
    .get 'shelves'
    .then (shelvesObj) -> _.values shelvesObj

  countShelves: (userId)->
    _.preq.get app.API.shelves.byOwners(userId)
    .get 'shelves'
    .then (shelves)-> Object.keys(shelves).length

shelfActionReq = (id, itemsIds, action)->
  _.preq.post app.API.shelves[action], { id, items: itemsIds }
  .then getShelf
  .then (shelf)->
    itemsCount = shelf.items.length
    app.vent.trigger 'refresh:shelves:items', id, itemsCount
  .catch app.Execute('show:error')

getShelf = (res)->
  shelvesObj = res.shelves
  Object.values(shelvesObj)[0]
