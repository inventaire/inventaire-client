Works = require '../../collections/works'

module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P50'

  _.extend @, specificMethods

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
    booksUris = worksData.books.filter(isntSeriePart).map getUri
    articlesUris = worksData.articles.filter(isntSeriePart).map getUri

    @works =
      series: new Works null, { uris: serieUris }
      books: new Works null, { uris: booksUris }
      articles: new Works null, { uris: articlesUris }

getUri = _.property 'uri'

IsntSeriePart = (seriesUris)-> (workData)-> workData.serie not in seriesUris
