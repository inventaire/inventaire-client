Works = require '../../collections/works'

module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P50'

  setEbooksData.call @

  _.extend @, specificMethods

setEbooksData = ->
  hasGutenbergPage = @get('claims.wdt:P1938.0')?
  hasWikisourcePage = @get('wikisource.url')?
  @set 'hasEbooks', (hasGutenbergPage or hasWikisourcePage)
  @set 'gutenbergProperty', 'wdt:P1938'

specificMethods =
  initAuthorWorks: (refresh)->
    if not refresh and @waitForWorks? then return @waitForWorks

    uri = @get 'uri'

    @waitForWorks = _.preq.get app.API.entities.authorWorks(uri, refresh)
    .then _.Log("author work - #{uri}")
    .then @initWorksCollections.bind(@)

  initWorksCollections: (worksData)->
    serieUris = worksData.series.map getUri
    isntSeriePart = IsntSeriePart(serieUris)
    # Filter-out works that are part of a serie and will be displayed
    # in the serie layout
    worksUris = worksData.works.filter(isntSeriePart).map getUri
    articlesUris = worksData.articles.filter(isntSeriePart).map getUri

    @works =
      series: new Works null, { uris: serieUris }
      works: new Works null, { uris: worksUris }
      articles: new Works null, { uris: articlesUris }

  buildTitle: ->
    author = @get 'label'
    return _.i18n 'books_by_author', { author }

getUri = _.property 'uri'

IsntSeriePart = (seriesUris)-> (workData)-> workData.serie not in seriesUris
