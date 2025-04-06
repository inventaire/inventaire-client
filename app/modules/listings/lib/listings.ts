import { pluck } from 'underscore'
import { API } from '#app/api/api'
import type { ListingByCreatorsParams } from '#app/api/listings'
import type { MetadataUpdate } from '#app/lib/metadata/update'
import preq from '#app/lib/preq'
import { getEntitiesAttributesByUris, getEntitiesImagesUrls, serializeEntity, type SerializedEntity } from '#entities/lib/entities'
import { addEntitiesImages } from '#entities/lib/types/work_alt'
import { askConfirmation } from '#general/lib/confirmation_modal'
import type { ListingElement, ListingElementId } from '#server/types/element'
import type { EntityUri } from '#server/types/entity'
import type { Listing, ListingId } from '#server/types/listing'
import type { UserId } from '#server/types/user'
import { getCurrentLang, I18n, i18n } from '#user/lib/i18n'
import { getUserById } from '#users/users_data'

export interface ListingElementWithEntity extends ListingElement {
  entity: SerializedEntity
}

export async function getListingWithElementsById (id: ListingId) {
  const { list: listing } = await preq.get(API.listings.byId(id))
  return { listing }
}

export async function getElementById (id: ListingId) {
  const { element, list: listing } = await preq.get(API.listings.byElementId(id))
  return { element, listing }
}

export async function getListingsByCreators (params: ListingByCreatorsParams) {
  const { lists: listings } = await preq.get(API.listings.byCreators(params))
  return { listings }
}

export async function createListing (list: Pick<Listing, 'name' | 'description' | 'visibility' | 'type'>) {
  const { list: listing } = await preq.post(API.listings.create, list)
  return { listing }
}

export function deleteListing (params) {
  return preq.post(API.listings.delete, params)
}

export async function getListingsByEntityUri (uri: EntityUri) {
  const { lists } = await preq.get(API.listings.byEntities({ uris: [ uri ] }))
  return lists
}

export async function getUserListingsByEntityUri ({ userId, uri }: { userId: UserId, uri: EntityUri }) {
  const { listings } = await getListingsByCreators({ usersIds: [ userId ] })
  const listingsIds = pluck(listings, '_id')
  return getListingsContainingEntityUri({ listingsIds, uri })
}

export async function getListingsContainingEntityUri ({ listingsIds, uri }: { listingsIds: ListingId[], uri: EntityUri }) {
  if (listingsIds.length === 0) return []
  const { lists } = await preq.get(API.listings.byEntities({ uris: [ uri ], lists: listingsIds }))
  return lists
}

export async function getElementByUri ({ listingId, uri }: { listingId: ListingId, uri: EntityUri }) {
  const listing = await getListingsContainingEntityUri({ listingsIds: [ listingId ], uri })
  const { elements } = listing[0]
  return elements.find(el => el.uri === uri)
}

export async function updateListing (list: { id: ListingId } & Pick<Listing, 'name' | 'description' | 'visibility' >) {
  const { list: listing } = await preq.put(API.listings.update, list)
  return { listing }
}

export async function addElement (id: ListingId, uri: EntityUri) {
  return preq.post(API.listings.addElements, { id, uris: [ uri ] })
}

export async function removeElement (id: ListingId, uri: EntityUri) {
  return preq.post(API.listings.removeElements, { id, uris: [ uri ] })
}

export async function updateElement (params) {
  try {
    const res = preq.post(API.listings.updateElement, params)
    return res
  } catch (err) {
    if (err.message !== 'nothing to update') {
      throw err
    }
  }
}

export function serializeListing (listing) {
  const { _id: id } = listing
  return Object.assign(listing, {
    pathname: getListingPathname(id),
  })
}

export async function countListings (userId: UserId) {
  const { listings } = await getListingsByCreators({ usersIds: [ userId ] })
  return Object.keys(listings).length
}

export const getListingPathname = (id: ListingId) => `/lists/${id}`

export function getElementPathname (listingId: ListingId, elementId: ListingElementId) {
  return `/lists/${listingId}/element/${elementId}`
}

export async function getListingMetadata (listing: Listing) {
  return {
    title: await getListingLongTitle(listing),
    description: listing.description,
    url: getListingPathname(listing._id),
    smallCardType: true,
  }
}

export async function getElementMetadata (listing: Listing, element: ListingElementWithEntity) {
  return {
    title: await getElementTitle(listing, element),
    url: getElementPathname(listing._id, element._id),
    smallCardType: true,
  } as MetadataUpdate
}

async function getListingLongTitle (listing: Listing) {
  const { name, creator } = listing
  const { username } = await getUserById(creator)
  return `${name} - ${i18n('list_created_by', { username })}`
}

async function getElementTitle (listing: Listing, element: ListingElementWithEntity) {
  const { entity } = element
  const { name, creator } = listing
  const { username } = await getUserById(creator)
  return `${entity.title} - ${name} - ${i18n('list_created_by', { username })}`
}

export async function askUserConfirmationAndRemove (removeElementPromise, deletingData) {
  if (deletingData) {
    askConfirmation({
      confirmationText: i18n('Are you sure you want to **delete this element**? That will also delete the following text: %{deletingData}…', { deletingData: deletingData.slice(0, 50) }),
      warningText: I18n('cant_undo_warning'),
      action: removeElementPromise,
    })
  } else {
    await removeElementPromise()
  }
}

export async function assignEntitiesToElements (elements: ListingElement[]) {
  const uris = pluck(elements, 'uri')
  const res = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'info', 'labels', 'claims', 'image' ],
    lang: getCurrentLang(),
  })
  const entitiesByUris = res.entities
  const entities = Object.values(entitiesByUris).map(serializeEntity)
  await addEntitiesImages(entities)
  return elements.map(element => {
    // @ts-expect-error
    element.entity = entitiesByUris[element.uri]
    return element
  }) as ListingElementWithEntity[]
}

export const getElementsImages = async (elements: ListingElement[], imagesLimit: number) => {
  const allElementsUris = pluck(elements, 'uri')

  let imagesUrls = []
  let limit = 0
  const fetchMoreImages = async (offset = 0, amount = 10) => {
    const enoughImages = imagesUrls.length >= imagesLimit
    if (enoughImages) return
    limit = offset + 10
    const elementsUris = allElementsUris.slice(offset, limit)
    const someImagesUrls = await getEntitiesImagesUrls(elementsUris)
    imagesUrls = [ ...imagesUrls, ...someImagesUrls ]
    if (elementsUris.length === 0) return
    offset = amount
    amount += amount
    return fetchMoreImages(offset, amount)
  }
  await fetchMoreImages()
  return imagesUrls
}
