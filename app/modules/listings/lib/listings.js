import preq from '#lib/preq'

export const getListingWithSelectionsById = async id => {
  const { list: listing } = await preq.get(app.API.listings.byId(id))
  return { listing }
}

export const getListingsByCreator = async userId => {
  const { lists: listings } = await preq.get(app.API.listings.byCreators(userId))
  return { listings }
}

export const createListing = async list => {
  const { list: listing } = await preq.post(app.API.listings.create, list)
  return { listing }
}

export const getListingsByEntityUri = async uri => {
  const { lists } = await preq.get(app.API.listings.byEntities(uri))
  return lists[uri] ? lists[uri] : []
}

export const updateListing = async list => {
  const { list: listing } = await preq.put(app.API.listings.update, list)
  return { listing }
}

export const addSelection = async (id, uri) => {
  return preq.post(app.API.listings.addSelections, { id, uris: [ uri ] })
}

export const removeSelection = async (id, uri) => {
  return preq.post(app.API.listings.removeSelections, { id, uris: [ uri ] })
}

export const serializeListing = listing => {
  const { _id: id } = listing
  return Object.assign(listing, {
    pathname: `/lists/${id}`
  })
}
