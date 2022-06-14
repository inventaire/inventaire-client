import { getReverseClaims, getEntitiesByUris } from '#entities/lib/entities'

const subEntitiesProp = { work: 'wdt:P629' }

export const getSubEntities = async (type, uri) => {
  const subEntitiesUris = await getReverseClaims(subEntitiesProp[type], uri, true)

  return getEntitiesByUris({ uris: subEntitiesUris })
}

export const bestImage = function (a, b) {
  const { lang: userLang } = app.user
  if (a.isCompositeEdition !== b.isCompositeEdition) {
    if (a.isCompositeEdition) return 1
    else return -1
  } else if (a.lang === b.lang) {
    return latestPublication(a, b)
  } else if (a.lang === userLang) {
    return -1
  } else if (b.lang === userLang) {
    return 1
  } else {
    return latestPublication(a, b)
  }
}

const latestPublication = (a, b) => b.publicationTime - a.publicationTime

