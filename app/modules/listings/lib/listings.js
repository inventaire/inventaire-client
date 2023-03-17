import preq from '#lib/preq'
import { i18n } from '#user/lib/i18n'
import { pluck } from 'underscore'

export const getListingWithElementsById = async (id, limit) => {
  const { list: listing } = await preq.get(app.API.listings.byId(id, limit))
  return { listing }
}

export const getListingsByCreators = async params => {
  const { lists: listings } = await preq.get(app.API.listings.byCreators(params))
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
  const { listings } = await getListingsByCreators({ usersIds: userId })
  const listingsIds = pluck(listings, '_id')
  return getListingsContainingEntityUri({ listingsIds, uri })
}

export const getListingsContainingEntityUri = async ({ listingsIds, uri }) => {
  if (listingsIds.length === 0) return []
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
