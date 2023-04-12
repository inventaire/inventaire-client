import { getEntitiesAttributesByUris, serializeEntity } from '#entities/lib/entities'
import { extendedAuthorsKeys } from '#entities/lib/show_all_authors_preview_lists'
import { compact, pick, uniq } from 'underscore'

const authorProperties = Object.keys(extendedAuthorsKeys)

export async function getItemEntityData (uri) {
  const { entities } = await getEntitiesAttributesByUris({
    uris: [ uri ],
    attributes: [ 'type', 'labels', 'claims', 'image' ],
    lang: app.user.lang,
    relatives: [
      'wdt:P629',
      'wdt:P179',
      ...authorProperties,
    ]
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

const getWorksSeriesUris = works => uniq(compact(works.flatMap(getWorkSeriesUris)))
const getWorkSeriesUris = work => work.claims['wdt:P179']

const getWorksAuthorsUris = works => uniq(works.flatMap(getWorkAuthorsUris))
const getWorkAuthorsUris = work => Object.values(pick(work.claims, authorProperties))

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

  for (const [ property, authors ] of Object.entries(authorsByProperty)) {
    authorsByProperty[property] = uniq(authors).map(serializeEntity)
  }

  return authorsByProperty
}
