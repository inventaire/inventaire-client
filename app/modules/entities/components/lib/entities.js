import { getReverseClaims, getEntitiesByUris } from '#entities/lib/entities'
import preq from '#lib/preq'
import { pluck } from 'underscore'

const subEntitiesProp = {
  work: 'wdt:P629',
  serie: 'wdt:P179',
}

const urisGetterByType = {
  serie: async uri => {
    const { parts } = await preq.get(app.API.entities.serieParts(uri))
    return pluck(parts, 'uri')
  },
  human: async uri => {
    // TODO: also handle series and articles
    const { works } = await preq.get(app.API.entities.authorWorks(uri))
    return pluck(works, 'uri')
  },
}

export const getSubEntities = async (type, uri) => {
  let subEntitiesUris
  if (urisGetterByType[type]) {
    const getSubEntitiesUris = urisGetterByType[type]
    subEntitiesUris = await getSubEntitiesUris(uri)
  } else {
    subEntitiesUris = await getReverseClaims(subEntitiesProp[type], uri)
  }
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

export const buildAltUri = (uri, id) => {
  if (id && (uri.split(':')[1] !== id)) {
    return `inv:${id}`
  }
}
