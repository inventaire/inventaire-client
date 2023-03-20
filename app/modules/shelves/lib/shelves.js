import { forceArray } from '#lib/utils'
import preq from '#lib/preq'
import { getVisibilitySummary, getVisibilitySummaryLabel, visibilitySummariesData } from '#general/lib/visibility'
import { getColorHexCodeFromModelId, getColorSquareDataUri } from '#lib/images'
import assert_ from '#lib/assert_types'

export function getById (id) {
  return preq.get(app.API.shelves.byIds(id))
  .then(getShelf)
}

export async function getByIds (ids) {
  if (ids.length === 0) return {}
  const { shelves } = await preq.get(app.API.shelves.byIds(ids))
  return shelves
}

export async function createShelf (params) {
  const { shelf } = await preq.post(app.API.shelves.create, params)
  return shelf
}

export async function updateShelf (params) {
  try {
    const { shelf } = await preq.post(app.API.shelves.update, params)
    return shelf
  } catch (err) {
    if (err.message !== 'nothing to update') {
      throw err
    }
  }
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

export async function addItemsByIdsToShelf ({ shelfId, itemsIds }) {
  return shelfActionReq(shelfId, itemsIds, 'addItems')
}

export async function getShelvesByOwner (userId) {
  assert_.string(userId)
  const { shelves } = await preq.get(app.API.shelves.byOwners(userId))
  return Object.values(shelves)
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

export function serializeShelf (shelf) {
  const { _id, visibility } = shelf
  let { color } = shelf
  color = color || getColorHexCodeFromModelId(_id)
  Object.assign(shelf, {
    pathname: `/shelves/${_id}`,
    picture: getColorSquareDataUri(color),
    isEditable: shelf.owner === app.user.id
  })
  if (visibility) {
    const visibilitySummary = getVisibilitySummary(visibility)
    Object.assign(shelf, {
      iconData: visibilitySummariesData[visibilitySummary],
      iconLabel: getVisibilitySummaryLabel(visibility),
    })
  }
  return shelf
}

export async function getShelves (shelvesIds, mainUserIsOwner) {
  if (mainUserIsOwner) {
    const { shelves } = await preq.get(app.API.shelves.byOwners(app.user.id))
    return shelves
  } else {
    return getByIds(shelvesIds)
  }
}
