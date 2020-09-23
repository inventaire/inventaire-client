/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-var,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import PaginatedWorks from '../../collections/paginated_works'

export default function () {
  // Main property by which sub-entities are linked to this one
  this.childrenClaimProperty = 'wdt:P50'

  setEbooksData.call(this)

  return _.extend(this, specificMethods)
};

var setEbooksData = function () {
  const hasInternetArchivePage = (this.get('claims.wdt:P724.0') != null)
  const hasGutenbergPage = (this.get('claims.wdt:P1938.0') != null)
  const hasWikisourcePage = (this.get('wikisource.url') != null)
  this.set('hasEbooks', (hasInternetArchivePage || hasGutenbergPage || hasWikisourcePage))
  return this.set('gutenbergProperty', 'wdt:P1938')
}

var specificMethods = {
  fetchWorksData (refresh) {
    if (!refresh && (this.waitForWorksData != null)) { return this.waitForWorksData }
    const uri = this.get('uri')
    return this.waitForWorksData = _.preq.get(app.API.entities.authorWorks(uri, refresh))
  },

  initAuthorWorks (refresh) {
    refresh = this.getRefresh(refresh)
    if (!refresh && (this.waitForWorks != null)) { return this.waitForWorks }

    return this.waitForWorks = this.fetchWorksData(refresh)
      .then(this.initWorksCollections.bind(this))
  },

  initWorksCollections (worksData) {
    const seriesUris = worksData.series.map(getUri)
    // Filter-out works that are part of a serie and will be displayed
    // in the serie layout
    const worksUris = getWorksUris(worksData.works, seriesUris)
    const articlesUris = getWorksUris(worksData.articles, seriesUris)

    return this.works = {
      series: new PaginatedWorks(null, { uris: seriesUris, defaultType: 'serie' }),
      works: new PaginatedWorks(null, { uris: worksUris, defaultType: 'work' }),
      articles: new PaginatedWorks(null, { uris: articlesUris, defaultType: 'article' })
    }
  },

  buildTitle () { return _.i18n('books_by_author', { author: this.get('label') }) }
}

var getUri = _.property('uri')

var getWorksUris = (works, seriesUris) => works
.filter(workData => !seriesUris.includes(workData.serie))
.map(getUri)
