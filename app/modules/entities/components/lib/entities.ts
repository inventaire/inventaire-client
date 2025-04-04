import { pick, pluck } from 'underscore'
import { API } from '#app/api/api'
import { isNonEmptyArray } from '#app/lib/boolean_tests'
import preq from '#app/lib/preq'
import { objectEntries } from '#app/lib/utils'
import { aggregateWorksClaims, inverseLabels } from '#entities/components/lib/claims_helpers'
import { byPublicationDate, getReverseClaims, getEntities, serializeEntity, getEntitiesAttributesByUris, type SerializedEntity } from '#entities/lib/entities'
import { entityDataShouldBeRefreshed } from '#entities/lib/entity_refresh'
import { fetchRelatedEntities } from '#entities/lib/fetch_related_entities'
import { addEntitiesImages } from '#entities/lib/types/work_alt'
import type { SortFunction } from '#server/types/common'
import type { ExtendedEntityType, PropertyUri } from '#server/types/entity'
import { i18n, I18n } from '#user/lib/i18n'
import { mainUser } from '#user/lib/main_user'

const subEntitiesProp = {
  work: 'wdt:P629',
  serie: 'wdt:P179',
}

const urisGetterByType = {
  serie: async ({ entity, refresh }) => {
    const { uri: parentUri } = entity

    const { parts } = await preq.get(API.entities.serieParts(parentUri, refresh))
    return [
      {
        subEntityType: 'work',
        parentUri,
        parentEntity: entity,
        uris: pluck(parts, 'uri'),
        subEntityRelationProperty: 'wdt:P179',
        sortingType: 'seriePart',
      },
    ]
  },
  human: async ({ entity, refresh }) => {
    const { uri: parentUri } = entity
    const subEntityRelationProperty = 'wdt:P50'

    const { series, works, articles } = await preq.get(API.entities.authorWorks(parentUri, refresh))
    return [
      {
        label: I18n('series'),
        subEntityType: 'serie',
        parentUri,
        parentEntity: entity,
        subEntityRelationProperty,
        uris: pluck(series, 'uri'),
      },
      {
        label: I18n('works'),
        subEntityType: 'work',
        parentUri,
        parentEntity: entity,
        subEntityRelationProperty,
        uris: pluck(works, 'uri'),
      },
      {
        label: I18n('articles'),
        uris: pluck(articles,
          'uri'),
        searchable: false,
        isCompactDisplay: true,
        sortingType: 'article',
      },
    ]
  },
  publisher: async ({ entity, refresh }) => {
    const { uri: parentUri } = entity
    const subEntityRelationProperty = 'wdt:P123'

    const { collections, editions } = await preq.get(API.entities.publisherPublications(parentUri, refresh))
    return [
      {
        label: I18n('collections'),
        subEntityType: 'collection',
        parentUri,
        parentEntity: entity,
        subEntityRelationProperty,
        uris: pluck(collections, 'uri'),
      },
      {
        label: I18n('editions'),
        subEntityType: 'edition',
        parentUri,
        parentEntity: entity,
        subEntityRelationProperty,
        uris: pluck(editions, 'uri'),
        searchable: false,
      },
    ]
  },
  collection: async ({ entity, refresh }) => {
    const { uri: parentUri } = entity
    const subEntityRelationProperty = 'wdt:P195'

    const uris = await getReverseClaims(subEntityRelationProperty, parentUri, refresh)
    return [
      {
        label: I18n('editions'),
        subEntityType: 'edition',
        parentUri,
        parentEntity: entity,
        subEntityRelationProperty,
        uris,
        searchable: false,
      },
    ]
  },
  article: async ({ entity }) => {
    const { claims } = entity
    const uris = claims['wdt:P2860']
    return [
      {
        label: I18n('cites articles'),
        uris,
        searchable: false,
        isCompactDisplay: true,
        sortingType: 'article',
      },
    ]
  },
  claim: async ({ entity, property, refresh }) => {
    const { uri, label: entityLabel } = entity
    const uris = await getReverseClaims(property, uri, refresh)
    const propLabel = inverseLabels[property] || ''
    const label = i18n(propLabel, { name: entityLabel })
    let sortingType
    if (property === 'wdt:P69') sortingType = null
    else sortingType = 'work'
    return [
      { label, uris, sortingType },
    ]
  },
}

interface GetSubEntitiesSectionsParams {
  entity: SerializedEntity
  sortFn?: SortFunction<SerializedEntity>
  property?: PropertyUri
}
export async function getSubEntitiesSections ({ entity, sortFn = byPublicationDate, property }: GetSubEntitiesSectionsParams) {
  const { uri, type } = entity
  const refresh = entityDataShouldBeRefreshed(uri)
  let sections
  if (property) {
    const getSubEntitiesUris = urisGetterByType.claim
    sections = await getSubEntitiesUris({ entity, property, refresh })
  } else {
    const getSubEntitiesUris = urisGetterByType[type]
    sections = await getSubEntitiesUris({ entity, refresh })
  }
  await Promise.all(sections.map(fetchSectionEntities({ sortFn, parentEntityType: type })))
  return sections
}

// Limiting the amount of entities to not overload the server
// ie. `entity/wdt:P1433-wd:Q180445`
// Ideas to increase limit:
//   - batch requests and retry on failure and handle facets entities queries the same way
//   - or build facets on the server (like with inventory-view for the inventory browser), and only display the first entities of the facet-filtered list, fetching more on scroll.
const entitiesLimit = 200
const limitedTypes = new Set([ 'publisher', 'genre', 'subject', 'article' ])

function truncateTooManyUris (section, parentEntityType) {
  const { uris = [] } = section
  const urisCount = uris.length
  if (urisCount < entitiesLimit) return
  if (limitedTypes.has(parentEntityType)) {
    section.uris = uris.splice(0, entitiesLimit)
    section.context = i18n('Too many entities requested (%{entitiesCount}). Only %{limit} are displayed.', {
      entitiesCount: urisCount,
      limit: entitiesLimit,
    })
  }
}

export const fetchSectionEntities = ({ sortFn, parentEntityType }: { sortFn?: any, parentEntityType: ExtendedEntityType }) => async section => {
  truncateTooManyUris(section, parentEntityType)
  const uris = section?.uris || []
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes: [
      'info',
      'labels',
      'descriptions',
      'claims',
      'image',
    ],
    lang: mainUser.lang,
  })

  // This prevents displaying several entities with the same canonical uri
  // as might happen if both inv and wd queries returned conflicting entities
  // TODO: remove once all inv and wd entities sharing the same ISBN have been merged
  if (uris.some(uri => uri.startsWith('isbn'))) {
    for (const [ uri, entity ] of objectEntries(entities)) {
      if (entity.uri !== uri && entities[uri] != null) delete entities[entity.uri]
    }
  }

  section.entities = Object.values(entities).map(serializeEntity).sort(sortFn)
  await addEntitiesImages(section.entities)
  await fetchRelatedEntities(section.entities, parentEntityType)
  return section
}

export async function getSubEntities (type, uri) {
  const uris = await getReverseClaims(subEntitiesProp[type], uri)
  return getEntities(uris)
}

export const bestImage = function (a, b) {
  const { lang: userLang } = mainUser
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

export function addWorksClaims (claims, works) {
  const worksClaims = aggregateWorksClaims(works)
  const nonEmptyWorksClaims = pick(worksClaims, isNonEmptyArray)
  return Object.assign(claims, nonEmptyWorksClaims)
}
