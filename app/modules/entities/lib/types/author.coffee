Works = require '../../collections/works'

module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P50'

  setEbooksData.call @

  # Fetching the author's works is optional, currently only triggered
  # by the author_layout, thus the definition of waitForSubentities
  # as a resolved promise
  @waitForSubentities = _.preq.resolved

  _.extend @, specificMethods

setEbooksData = ->
  hasGutenbergPage = @get('claims.wdt:P1938.0')?
  hasWikisourcePage = @get('wikisource.url')?
  @set 'hasEbooks', (hasGutenbergPage or hasWikisourcePage)
  @set 'gutenbergProperty', 'wdt:P1938'

specificMethods =
  initAuthorWorks: (refresh)->
    refresh = @getRefresh refresh
    if not refresh and @waitForWorks? then return @waitForWorks

    @waitForWorks = @getWorksData refresh
    .then @initWorksCollections.bind(@)

  getWorksData: (refresh)->
    uri = @get 'uri'
    _.preq.get app.API.entities.authorWorks(uri, refresh)

  initWorksCollections: (worksData)->
    seriesUris = worksData.series.map getUri
    # Filter-out works that are part of a serie and will be displayed
    # in the serie layout
    worksUris = getWorksUris worksData.works, seriesUris
    articlesUris = getWorksUris worksData.articles, seriesUris

    @works =
      series: new Works null, { uris: seriesUris, defaultType: 'serie' }
      works: new Works null, { uris: worksUris, defaultType: 'work' }
      articles: new Works null, { uris: articlesUris, defaultType: 'article' }

  buildTitle: -> _.i18n 'books_by_author', { author: @get('label') }

getUri = _.property 'uri'

getWorksUris = (works, seriesUris)->
  works
  .filter (workData)-> workData.serie not in seriesUris
  .map getUri
