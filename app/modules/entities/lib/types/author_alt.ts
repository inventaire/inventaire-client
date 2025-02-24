import { property } from 'underscore'
import { API } from '#app/api/api'
import preq from '#app/lib/preq'
import { objectEntries } from '#app/lib/utils'
import { propertiesByRoles } from '#entities/components/lib/claims_helpers'
import { attachEntities, getEntitiesAttributesByUris, getEntities, serializeEntity, type SerializedEntity } from '#entities/lib/entities'
import { pluralize } from '#entities/lib/types/entities_types'
import type { AuthorProperty } from '../properties'

export async function getAuthorWorksUris ({ uri }) {
  const { articles, series, works } = await preq.get(API.entities.authorWorks(uri))
  const seriesUris = series.map(getUri)
  const worksUris = getWorksUris(works, seriesUris)
  const articlesUris = getWorksUris(articles, seriesUris)
  return { seriesUris, worksUris, articlesUris }
}

export async function addAuthorWorks (author) {
  const { seriesUris, worksUris, articlesUris } = await getAuthorWorksUris(author)
  await Promise.all([
    attachEntities(author, 'articles', articlesUris),
    attachEntities(author, 'series', seriesUris),
    attachEntities(author, 'works', worksUris),
  ])
  return author
}

export async function getAuthorExtendedWorks ({ uri, attributes }) {
  const { seriesUris, worksUris, articlesUris } = await getAuthorWorksUris({ uri })
  const [ series, works, articles ] = await Promise.all([
    getEntitiesAttributesByUris({ uris: seriesUris, attributes }).then(listAndSerialize),
    getEntitiesAttributesByUris({ uris: worksUris, attributes }).then(listAndSerialize),
    getEntitiesAttributesByUris({ uris: articlesUris, attributes }).then(listAndSerialize),
  ])
  return { series, works, articles }
}

const listAndSerialize = ({ entities }) => Object.values(entities).map(serializeEntity)

type WorkEntity = SerializedEntity & {
  authors?: SerializedEntity[]
  coauthors?: SerializedEntity[]
}

export async function getAuthorWorks ({ uri }) {
  const { works } = await preq.get(API.entities.authorWorks(uri))
  const worksUris = works.map(getUri)
  const worksEntities: WorkEntity[] = await getEntities(worksUris)
  // Filtering-out any non-work undetected by the SPARQL query
  return worksEntities.filter(isWork)
}

function isWork (entity: SerializedEntity) {
  return entity.type === 'work'
}

const getUri = property('uri')

const getWorksUris = (works, seriesUris) => {
  return works
  .filter(workData => !seriesUris.includes(workData.serie))
  .map(getUri)
}

const _extendedAuthorsKeys = {}

for (const [ roleLabel, properties ] of objectEntries(propertiesByRoles)) {
  const [ property ] = properties
  _extendedAuthorsKeys[property] = pluralize(roleLabel)
}

export const extendedAuthorsKeys = _extendedAuthorsKeys as Record<AuthorProperty, string>
