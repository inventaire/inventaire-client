PaginatedWorks = require '../../collections/paginated_works'

module.exports = ->
  # Main property by which sub-entities are linked to this one
  @childrenClaimProperty = 'wdt:P50'

  setEbooksData.call @

  _.extend @, specificMethods

setEbooksData = ->
  hasInternetArchivePage = @get('claims.wdt:P724.0')?
  hasGutenbergPage = @get('claims.wdt:P1938.0')?
  hasWikisourcePage = @get('wikisource.url')?
  @set 'hasEbooks', (hasInternetArchivePage or hasGutenbergPage or hasWikisourcePage)
  @set 'gutenbergProperty', 'wdt:P1938'

specificMethods =
  fetchWorksData: (refresh)->
    if not refresh and @waitForWorksData? then return @waitForWorksData
    uri = @get 'uri'
    @waitForWorksData = _.preq.get app.API.entities.authorWorks(uri, refresh)

  initAuthorWorks: (refresh)->
    refresh = @getRefresh refresh
    if not refresh and @waitForWorks? then return @waitForWorks

    @waitForWorks = @fetchWorksData refresh
      .then @initWorksCollections.bind(@)

  initWorksCollections: (worksData)->
    seriesUris = worksData.series.map getUri
    # Filter-out works that are part of a serie and will be displayed
    # in the serie layout
    worksUris = getWorksUris worksData.works, seriesUris
    articlesUris = getWorksUris worksData.articles, seriesUris

    @works =
      series: new PaginatedWorks null, { uris: seriesUris, defaultType: 'serie' }
      works: new PaginatedWorks null, { uris: worksUris, defaultType: 'work' }
      articles: new PaginatedWorks null, { uris: articlesUris, defaultType: 'article' }

  buildTitle: -> _.i18n 'books_by_author', { author: @get('label') }

getUri = _.property 'uri'

getWorksUris = (works, seriesUris)->
  works
  .filter (workData)-> workData.serie not in seriesUris
  .map getUri
