import { compact, pick, uniq, values } from 'underscore'
import { objectEntries, objectKeys } from '#app/lib/utils'
import { getEntitiesAttributesByUris, serializeEntity, type SerializedEntity } from '#entities/lib/entities'
import { extendedAuthorsKeys } from '#entities/lib/types/author_alt'
import { getCurrentLang } from '#modules/user/lib/i18n'

const authorProperties = objectKeys(extendedAuthorsKeys)
const relatives = [
  'wdt:P629',
  'wdt:P179',
  ...authorProperties,
] as const

export async function getItemEntityData (uri) {
  const { entities } = await getEntitiesAttributesByUris({
    uris: [ uri ],
    attributes: [ 'info', 'labels', 'claims', 'image' ],
    lang: getCurrentLang(),
    relatives,
  })
  const getAndSerialize = uri => entities[uri] ? serializeEntity(entities[uri]) : null
  const entity = getAndSerialize(uri)
  let works
  if (entity.type === 'edition') {
    const worksUris = entity.claims['wdt:P629']
    works = compact(worksUris.map(getAndSerialize))
  } else if (entity.type === 'work') {
    // Legacy items might link directly to a work entity
    works = [ entity ]
  }
  const seriesUris = getWorksSeriesUris(works)
  const authorsUris = getWorksAuthorsUris(works)
  const series = compact(seriesUris.map(getAndSerialize))
  const authorsByUris = pick(entities, authorsUris)
  const authorsByProperty = getAuthorsByProperty({ works, authorsByUris })
  return { entity, works, series, authorsByProperty }
}

export function getWorksSeriesUris (works: SerializedEntity[]) {
  return uniq(compact(works.flatMap(getWorkSeriesUris)))
}
export function getWorkSeriesUris (work: SerializedEntity) {
  return work.claims['wdt:P179']
}

export function getWorksAuthorsUris (works: SerializedEntity[]) {
  return uniq(works.flatMap(getWorkAuthorsUris))
}
export function getWorkAuthorsUris (work: SerializedEntity) {
  return values(pick(work.claims, authorProperties)).flat()
}

function getAuthorsByProperty ({ works, authorsByUris }) {
  const authorsByProperty = Object.fromEntries(authorProperties.map(property => [ property, [] ]))

  for (const work of works) {
    for (const property of authorProperties) {
      const propertyAuthorsUris = work.claims[property]
      if (propertyAuthorsUris) {
        const propertyAuthors = Object.values(pick(authorsByUris, propertyAuthorsUris))
        authorsByProperty[property].push(...propertyAuthors)
      }
    }
  }

  for (const [ property, authors ] of objectEntries(authorsByProperty)) {
    authorsByProperty[property] = uniq(authors).map(serializeEntity)
  }

  return authorsByProperty
}
