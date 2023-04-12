import { pluck } from 'underscore'
import { API } from '#app/api/api'
import app from '#app/app'
import preq from '#app/lib/preq'
import { i18n } from '#user/lib/i18n'

export const getListingWithElementsById = async id => {
  const { list: listing } = await preq.get(API.listings.byId(id))
  return { listing }
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

export const reorder = async (id, uris) => {
  return preq.post(API.listings.reorder, { id, uris })
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

export async function getListingMetadata (listing) {
  return {
    title: await getListingLongTitle(listing),
    description: listing.description,
    url: getListingPathname(listing._id),
    smallCardType: true,
  }
}

export async function getListingLongTitle (listing) {
  const { name, creator } = listing
  const { username } = await app.request('get:user:data', creator)
  return `${name} - ${i18n('list_created_by', { username })}`
}
