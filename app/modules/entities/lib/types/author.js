import { i18n } from 'modules/user/lib/i18n'
import preq from 'lib/preq'
import { attachEntities, getEntitiesByUris } from '../entities'

export default function () {
  // Main property by which sub-entities are linked to this one
  this.childrenClaimProperty = 'wdt:P50'

  setEbooksData.call(this)

  return _.extend(this, specificMethods)
}

const setEbooksData = function () {
  const hasInternetArchivePage = (this.get('claims.wdt:P724.0') != null)
  const hasGutenbergPage = (this.get('claims.wdt:P1938.0') != null)
  const hasWikisourcePage = (this.get('wikisource.url') != null)
  this.set('hasEbooks', (hasInternetArchivePage || hasGutenbergPage || hasWikisourcePage))
  this.set('gutenbergProperty', 'wdt:P1938')
}

const specificMethods = {
  fetchWorksData (refresh) {
    if (!refresh && this.waitForWorksData != null) return this.waitForWorksData
    const uri = this.get('uri')
    this.waitForWorksData = preq.get(app.API.entities.authorWorks(uri, refresh))
    return this.waitForWorksData
  },

  initAuthorWorks (refresh) {
    refresh = this.getRefresh(refresh)
    if (!refresh && this.waitForWorks != null) return this.waitForWorks

    this.waitForWorks = this.fetchWorksData(refresh).then(initWorksCollections.bind(this))
    return this.waitForWorks
  },

  buildTitle () { return i18n('books_by_author', { author: this.get('label') }) }
}

const initWorksCollections = async function (worksData) {
  const seriesUris = worksData.series.map(getUri)
  // Filter-out works that are part of a serie and will be displayed
  // in the serie layout
  const worksUris = getWorksUris(worksData.works, seriesUris)
  const articlesUris = getWorksUris(worksData.articles, seriesUris)

  // Prevent circular dependencies by using a late import
  const { default: PaginatedWorks } = await import('../../collections/paginated_works')

  this.works = {
    series: new PaginatedWorks(null, { uris: seriesUris, defaultType: 'serie' }),
    works: new PaginatedWorks(null, { uris: worksUris, defaultType: 'work' }),
    articles: new PaginatedWorks(null, { uris: articlesUris, defaultType: 'article' })
  }

  return this.works
}

const getUri = _.property('uri')

const getWorksUris = (works, seriesUris) => {
  return works
  .filter(workData => !seriesUris.includes(workData.serie))
  .map(getUri)
}

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
