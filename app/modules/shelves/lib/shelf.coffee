ShelfModel = require '../models/shelf'

error_ = require 'lib/error'

module.exports =
  getById: (id)->
    _.preq.get app.API.shelves.byIds(id)
    .then getShelf
    .then (shelf)->
      if shelf? then new ShelfModel shelf
      else throw error_.new 'not found', 404, { id }

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

  getShelvesByOwner: ()->
    _.preq.get app.API.shelves.byOwners(app.user.id)
    .get 'shelves'
    .then (shelvesObj) -> _.values shelvesObj

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
