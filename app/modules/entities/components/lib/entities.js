import { i18n, I18n } from '#user/lib/i18n'
import { getReverseClaims, getEntitiesByUris, serializeEntity, getEntitiesAttributesByUris } from '#entities/lib/entities'
import { inverseLabels } from '#entities/components/lib/claims_helpers'
import { isNonEmptyArray } from '#lib/boolean_tests'
import { addWorksClaims, isSubentitiesTypeEdition } from './edition_layout_helpers'
import preq from '#lib/preq'
import { pluck } from 'underscore'
import { getEditionsWorks } from '#entities/lib/get_entity_view_by_type.js'
import { expired } from '#lib/utils'

const subEntitiesProp = {
  work: 'wdt:P629',
  serie: 'wdt:P179',
}

const urisGetterByType = {
  serie: async ({ entity, refresh }) => {
    const { uri: parentUri } = entity

    const { parts } = await preq.get(app.API.entities.serieParts(parentUri, refresh))
    return [
      {
        subEntityType: 'work',
        parentUri,
        uris: pluck(parts, 'uri'),
        subEntityRelationProperty: 'wdt:P179',
        sortingType: 'seriePart'
      },
    ]
  },
  human: async ({ entity, refresh }) => {
    const { uri: parentUri } = entity
    const subEntityRelationProperty = 'wdt:P50'

    const { series, works, articles } = await preq.get(app.API.entities.authorWorks(parentUri, refresh))
    return [
      {
        label: I18n('series'),
        subEntityType: 'serie',
        parentUri,
        subEntityRelationProperty,
        uris: pluck(series, 'uri')
      },
      {
        label: I18n('works'),
        subEntityType: 'work',
        parentUri,
        subEntityRelationProperty,
        uris: pluck(works, 'uri')
      },
      {
        label: I18n('articles'),
        uris: pluck(articles,
          'uri'),
        searchable: false
      },
    ]
  },
  publisher: async ({ entity, refresh }) => {
    const { uri: parentUri } = entity
    const subEntityRelationProperty = 'wdt:P123'

    const { collections, editions } = await preq.get(app.API.entities.publisherPublications(parentUri, refresh))
    return [
      {
        label: I18n('collections'),
        subEntityType: 'collection',
        parentUri,
        subEntityRelationProperty,
        uris: pluck(collections, 'uri')
      },
      {
        label: I18n('editions'),
        subEntityType: 'edition',
        parentUri,
        subEntityRelationProperty,
        uris: pluck(editions, 'uri'),
        searchable: false
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
        subEntityRelationProperty,
        uris,
        searchable: false
      },
    ]
  },
  article: async ({ entity }) => {
    const { claims } = entity
    const uris = claims['wdt:P2860']
    return [
      { label: I18n('cites articles'), uris, searchable: false },
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
  }
}

export const getSubEntitiesSections = async ({ entity, sortFn, property }) => {
  const { type, refreshTimestamp } = entity
  const refresh = refreshTimestamp && !expired(refreshTimestamp, 1000)
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

const truncateTooManyUris = (section, parentEntityType) => {
  const { uris = [] } = section
  const urisCount = uris.length
  if (urisCount < entitiesLimit) return
  if (limitedTypes.has(parentEntityType)) {
    section.uris = uris.splice(0, entitiesLimit)
    section.context = i18n('Too many entities requested (%{entitiesCount}). Only %{limit} are displayed.', {
      entitiesCount: urisCount,
      limit: entitiesLimit
    })
  }
}

const fetchSectionEntities = ({ sortFn, parentEntityType }) => async section => {
  truncateTooManyUris(section, parentEntityType)
  const { entities } = await getEntitiesAttributesByUris({
    uris: section.uris,
    attributes: [
      'info',
      'labels',
      'descriptions',
      'claims',
      'image',
    ],
    lang: app.user.lang
  })
  section.entities = Object.values(entities).map(serializeEntity).sort(sortFn)
  await fetchRelatedEntities(section.entities, parentEntityType)
  return section
}

async function fetchRelatedEntities (entities, parentEntityType) {
  if (isSubentitiesTypeEdition(parentEntityType)) {
    const relatedEntities = await getEditionsWorks(entities)
    Object.values(entities).forEach(pickAndAssignWorksClaims(relatedEntities))
  }
  await addWorksAuthors(entities)
}

export async function addWorksAuthors (works) {
  const authorsUris = _.uniq(_.compact(_.flatten(works.map(getWorkAuthorsUris))))
  const entities = await getEntitiesByUris({ uris: authorsUris, index: true })
  works.forEach(work => {
    const workAuthorUris = getWorkAuthorsUris(work)
    work.relatedEntities = _.pick(entities, workAuthorUris)
  })
}
const getWorkAuthorsUris = work => work.claims['wdt:P50']

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
