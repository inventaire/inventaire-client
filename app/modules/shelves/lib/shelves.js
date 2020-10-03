import { forceArray } from 'lib/utils'
import preq from 'lib/preq'

export default {
  getById (id) {
    return preq.get(app.API.shelves.byIds(id))
    .then(getShelf)
  },

  getByIds (ids) {
    console.log('ids', ids)
    return preq.get(app.API.shelves.byIds(ids))
    .get('shelves')
  },

  createShelf (params) {
    return preq.post(app.API.shelves.create, params)
    .get('shelf')
  },

  updateShelf (params) {
    return preq.post(app.API.shelves.update, params)
    .get('shelf')
  },

  deleteShelf (params) {
    return preq.post(app.API.shelves.delete, params)
  },

  removeItems (model, items) {
    const { id } = model
    items = forceArray(items)
    const itemsIds = items.map(item => {
      if (_.isString(item)) {
        return item
      } else {
        item.removeShelf(id)
        return item.get('_id')
      }
    })
    return shelfActionReq(id, itemsIds, 'removeItems')
  },

  addItems (model, items) {
    const { id } = model
    items = forceArray(items)
    const itemsIds = items.map(item => {
      if (_.isString(item)) {
        return item
      } else {
        item.createShelf(id)
        return item.get('_id')
      }
    })
    return shelfActionReq(id, itemsIds, 'addItems')
  },

  getShelvesByOwner (userId) {
    return preq.get(app.API.shelves.byOwners(userId))
    .get('shelves')
    .then(_.values)
  },

  countShelves (userId) {
    return preq.get(app.API.shelves.byOwners(userId))
    .get('shelves')
    .then(shelves => Object.keys(shelves).length)
  }
}

const shelfActionReq = (id, itemsIds, action) => preq.post(app.API.shelves[action], { id, items: itemsIds })
.then(getShelf)

const getShelf = function (res) {
  const shelvesObj = res.shelves
  return Object.values(shelvesObj)[0]
}
