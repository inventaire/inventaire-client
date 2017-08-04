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
    serieUris = worksData.series.map getUri
    isntSeriePart = IsntSeriePart(serieUris)
    # Filter-out works that are part of a serie and will be displayed
    # in the serie layout
    worksUris = worksData.works.filter(isntSeriePart).map getUri
    articlesUris = worksData.articles.filter(isntSeriePart).map getUri

    @works =
      series: new Works null, { uris: serieUris, defaultType: 'serie' }
      works: new Works null, { uris: worksUris, defaultType: 'work' }
      articles: new Works null, { uris: articlesUris, defaultType: 'article' }

  buildTitle: -> _.i18n 'books_by_author', { author: @get('label') }

getUri = _.property 'uri'

IsntSeriePart = (seriesUris)-> (workData)-> workData.serie not in seriesUris
