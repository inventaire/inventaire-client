import { pluck } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import preq from '#app/lib/preq'
import { getEntitiesAttributesByUris, serializeEntity } from '#entities/lib/entities'
import { addEntitiesImages } from '#entities/lib/types/work_alt'
import { i18n } from '#user/lib/i18n'

export const getListingWithElementsById = async id => {
  const { list: listing } = await preq.get(API.listings.byId(id))
  return { listing }
}

export const getElementById = async id => {
  const { element, list: listing } = await preq.get(API.listings.byElementId(id))
  return { element, listing }
}

export const getListingsByCreators = async params => {
  const { lists: listings } = await preq.get(API.listings.byCreators(params))
  return { listings }
}

export const createListing = async list => {
  const { list: listing } = await preq.post(API.listings.create, list)
  return { listing }
}

export function deleteListing (params) {
  return preq.post(API.listings.delete, params)
}

export const getListingsByEntityUri = async uri => {
  const { lists } = await preq.get(API.listings.byEntities({ uris: [ uri ] }))
  return lists
}

export const getUserListingsByEntityUri = async ({ userId, uri }) => {
  const { listings } = await getListingsByCreators({ usersIds: userId })
  const listingsIds = pluck(listings, '_id')
  return getListingsContainingEntityUri({ listingsIds, uri })
}

export const getListingsContainingEntityUri = async ({ listingsIds, uri }) => {
  if (listingsIds.length === 0) return []
  const { lists } = await preq.get(API.listings.byEntities({ uris: uri, lists: listingsIds }))
  return lists
}

export const getElementByUri = async ({ listingId, uri }) => {
  const listing = await getListingsContainingEntityUri({ listingsIds: [ listingId ], uri })
  const { elements } = listing[0]
  return elements.find(el => el.uri === uri)
}

export const updateListing = async list => {
  const { list: listing } = await preq.put(API.listings.update, list)
  return { listing }
}

export const addElement = async (id, uri) => {
  return preq.post(API.listings.addElements, { id, uris: [ uri ] })
}

export const removeElement = async (id, uri) => {
  return preq.post(API.listings.removeElements, { id, uris: [ uri ] })
}

export const updateElement = async params => {
  try {
    const res = preq.post(API.listings.updateElement, params)
    return res
  } catch (err) {
    if (err.message !== 'nothing to update') {
      throw err
    }
  }
}

export const serializeListing = listing => {
  const { _id: id } = listing
  return Object.assign(listing, {
    pathname: getListingPathname(id),
  })
}

export async function countListings (userId) {
  const { listings } = await getListingsByCreators({ usersIds: userId })
  return Object.keys(listings).length
}

export const getListingPathname = id => `/lists/${id}`

export const getElementPathname = (listingId, elementId) => `/lists/${listingId}/element/${elementId}`

export async function getListingMetadata (listing) {
  return {
    title: await getListingLongTitle(listing),
    description: listing.description,
    url: getListingPathname(listing._id),
    smallCardType: true,
  }
}

export async function getElementMetadata (listing, element) {
  return {
    title: await getElementTitle(listing, element),
    url: getElementPathname(listing._id, element._id),
    smallCardType: true,
  }
}

async function getListingLongTitle (listing) {
  const { name, creator } = listing
  const { username } = await app.request('get:user:data', creator)
  return `${name} - ${i18n('list_created_by', { username })}`
}

async function getElementTitle (listing, element) {
  const { entity } = element
  const { name, creator } = listing
  const { username } = await app.request('get:user:data', creator)
  return `${entity.title} - ${name} - ${i18n('list_created_by', { username })}`
}

export async function askUserConfirmationAndRemove (removeElementPromise, deletingData) {
  if (deletingData) {
    app.execute('ask:confirmation', {
      confirmationText: i18n('Are you sure you want to **delete this element**? That will also delete the following text: %{deletingData}…', { deletingData: deletingData.slice(0, 50) }),
      warningText: i18n('cant_undo_warning'),
      action: removeElementPromise,
    })
  } else {
    await removeElementPromise()
  }
}

export const assignEntitiesToElements = async elements => {
  const uris = pluck(elements, 'uri')
  const res = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'info', 'labels', 'claims', 'image' ],
    lang: app.user.lang,
  })
  const entitiesByUris = res.entities
  const entities = Object.values(entitiesByUris).map(serializeEntity)
  await addEntitiesImages(entities)
  for (const element of elements) {
    element.entity = entitiesByUris[element.uri]
  }
}
