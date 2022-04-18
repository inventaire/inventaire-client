import { getReverseClaims, getEntitiesByUris } from '#entities/lib/entities'

const subEntitiesProp = { work: 'wdt:P629' }

export const getSubEntities = async (type, uri) => {
  const subEntitiesUris = await getReverseClaims(subEntitiesProp[type], uri, true)

  return getEntitiesByUris({ uris: subEntitiesUris })
}
