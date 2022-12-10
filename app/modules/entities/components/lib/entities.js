import { getReverseClaims, getEntitiesByUris, serializeEntity, getEntitiesAttributesByUris } from '#entities/lib/entities'
import { inverseLabels } from '#entities/components/lib/claims_helpers'
import { isNonEmptyArray } from '#lib/boolean_tests'
import { addWorksImages } from '#entities/lib/types/work_alt'
import { addWorksClaims, isWorksClaimsContext } from './edition_layout_helpers'
import preq from '#lib/preq'
import { pluck } from 'underscore'
import { getEditionsWorks } from '#entities/lib/get_entity_view_by_type.js'

const subEntitiesProp = {
  work: 'wdt:P629',
  serie: 'wdt:P179',
}

const urisGetterByType = {
  serie: async uri => {
    const { parts } = await preq.get(app.API.entities.serieParts(uri))
    return [
      { uris: pluck(parts, 'uri') },
    ]
  },
  human: async uri => {
    // TODO: also handle articles
    const { series, works } = await preq.get(app.API.entities.authorWorks(uri))
    return [
      { label: 'series', uris: pluck(series, 'uri') },
      { label: 'works', uris: pluck(works, 'uri') },
    ]
  },
  publisher: async uri => {
    const { collections, editions } = await preq.get(app.API.entities.publisherPublications(uri))
    return [
      { label: 'collections', uris: pluck(collections, 'uri') },
      { label: 'editions', uris: pluck(editions, 'uri') },
    ]
  },
  collection: async uri => {
    const uris = await getReverseClaims('wdt:P195', uri)
    return [
      { label: 'editions', uris },
    ]
  },
  claim: async (uri, property) => {
    const uris = await getReverseClaims(property, uri)
    const label = inverseLabels[property] || ''
    return [
      { label, uris },
    ]
  }
}

export const getSubEntitiesSections = async ({ entity, sortFn, property }) => {
  const { type, uri } = entity
  let sections
  if (property) {
    const getSubEntitiesUris = urisGetterByType.claim
    sections = await getSubEntitiesUris(uri, property)
  } else {
    const getSubEntitiesUris = urisGetterByType[type]
    sections = await getSubEntitiesUris(uri)
  }
  await Promise.all(sections.map(fetchSectionEntities({ sortFn, parentEntityType: type })))
  return sections
}

const fetchSectionEntities = ({ sortFn, parentEntityType }) => async section => {
  const { entities } = await getEntitiesAttributesByUris({
    uris: section.uris,
    attributes: [
      'type',
      'labels',
      'descriptions',
      'claims',
      'image',
    ],
    lang: app.user.lang
  })
  section.entities = Object.values(entities).map(serializeEntity).sort(sortFn)
  await addWorksImages(section.entities)
  if (isWorksClaimsContext(parentEntityType)) {
    const relatedEntities = await getEditionsWorks(section.entities)
    Object.values(entities).forEach(pickAndAssignWorksClaims(relatedEntities))
  }
  return section
}

const pickAndAssignWorksClaims = relatedEntities => edition => {
  const { claims } = edition
  const editionWorks = relatedEntities.filter(isClaimValue(claims))
  if (isNonEmptyArray(editionWorks)) {
    edition.claims = addWorksClaims(claims, editionWorks)
  }
}

const isClaimValue = claims => entity => claims['wdt:P629'].includes(entity.uri)

export const getSubEntities = async (type, uri) => {
  const uris = await getReverseClaims(subEntitiesProp[type], uri)
  return getEntitiesByUris({ uris })
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
