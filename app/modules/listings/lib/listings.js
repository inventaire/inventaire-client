import preq from '#lib/preq'
import { pluck } from 'underscore'

export const getListingWithElementsById = async (id, limit) => {
  const { list: listing } = await preq.get(app.API.listings.byId(id, limit))
  return { listing }
}

export const getListingsByCreators = async (userId, withElements) => {
  const { lists: listings } = await preq.get(app.API.listings.byCreators(userId, withElements))
  return { listings }
}

export const createListing = async list => {
  const { list: listing } = await preq.post(app.API.listings.create, list)
  return { listing }
}

export function deleteListing (params) {
  return preq.post(app.API.listings.delete, params)
}

export const getListingsByEntityUri = async uri => {
  const { lists } = await preq.get(app.API.listings.byEntities({ uris: uri }))
  return lists[uri] ? lists[uri] : []
}

export const getUserListingsByEntityUri = async ({ userId, uri }) => {
  const { listings } = await getListingsByCreators(userId)
  const listingsIds = pluck(listings, '_id')
  return getListingsContainingEntityUri({ listingsIds, uri })
}

export const getListingsContainingEntityUri = async ({ listingsIds, uri }) => {
  const { lists: listingsByEntity } = await preq.get(app.API.listings.byEntities({ uris: uri, lists: listingsIds }))
  return listingsByEntity[uri]
}

export const updateListing = async list => {
  const { list: listing } = await preq.put(app.API.listings.update, list)
  return { listing }
}

export const addElement = async (id, uri) => {
  return preq.post(app.API.listings.addElements, { id, uris: [ uri ] })
}

export const removeElement = async (id, uri) => {
  return preq.post(app.API.listings.removeElements, { id, uris: [ uri ] })
}

export const serializeListing = listing => {
  const { _id: id } = listing
  return Object.assign(listing, {
    pathname: getListingPathname(id)
  })
}

export async function countListings (userId) {
  const { lists: listings } = await preq.get(app.API.listings.byCreators(userId))
  return Object.keys(listings).length
}

export const getListingPathname = id => `/lists/${id}`
