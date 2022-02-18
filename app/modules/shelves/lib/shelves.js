import { forceArray } from '#lib/utils'
import preq from '#lib/preq'

export function getById (id) {
  return preq.get(app.API.shelves.byIds(id))
  .then(getShelf)
}

export async function getByIds (ids) {
  const { shelves } = await preq.get(app.API.shelves.byIds(ids))
  return shelves
}

export async function createShelf (params) {
  const { shelf } = await preq.post(app.API.shelves.create, params)
  return shelf
}

export async function updateShelf (params) {
  const { shelf } = await preq.post(app.API.shelves.update, params)
  return shelf
}

export function deleteShelf (params) {
  return preq.post(app.API.shelves.delete, params)
}

export function removeItems (model, items) {
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
}

export function addItems (model, items) {
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
}

export async function getShelvesByOwner (userId) {
  const { shelves } = await preq.get(app.API.shelves.byOwners(userId))
  return _.values(shelves)
}

export async function countShelves (userId) {
  const { shelves } = await preq.get(app.API.shelves.byOwners(userId))
  return Object.keys(shelves).length
}

const shelfActionReq = (id, itemsIds, action) => {
  return preq.post(app.API.shelves[action], { id, items: itemsIds })
  .then(getShelf)
}

const getShelf = ({ shelves }) => Object.values(shelves)[0]
