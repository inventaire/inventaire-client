import preq from '#lib/preq'
import { attachEntities, getEntitiesAttributesByUris, getEntitiesByUris, serializeEntity } from '../entities.js'

export async function getAuthorWorksUris ({ uri }) {
  const { articles, series, works } = await preq.get(app.API.entities.authorWorks(uri))
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

export async function getAuthorWorks ({ uri }) {
  const { works } = await preq.get(app.API.entities.authorWorks(uri))
  const worksUris = works.map(getUri)
  const worksEntities = await getEntitiesByUris(worksUris)
  // Filtering-out any non-work undetected by the SPARQL query
  return worksEntities.filter(entity => entity.type === 'work')
}

const getUri = _.property('uri')

const getWorksUris = (works, seriesUris) => {
  return works
  .filter(workData => !seriesUris.includes(workData.serie))
  .map(getUri)
}

export const extendedAuthorsKeys = {
  'wdt:P50': 'authors',
  'wdt:P58': 'scenarists',
  'wdt:P110': 'illustrators',
  'wdt:P6338': 'colorists'
}
