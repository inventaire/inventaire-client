import preq from '#lib/preq'
import { attachEntities, getEntitiesByUris } from '../entities'

export const addAuthorWorks = async author => {
  const { uri } = author
  const { articles, series, works } = await preq.get(app.API.entities.authorWorks(uri))
  const seriesUris = series.map(getUri)
  const worksUris = getWorksUris(works, seriesUris)
  const articlesUris = getWorksUris(articles, seriesUris)
  await Promise.all([
    attachEntities(author, 'articles', articlesUris),
    attachEntities(author, 'series', seriesUris),
    attachEntities(author, 'works', worksUris),
  ])
  return author
}

export const getAuthorWorks = async ({ uri }) => {
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
