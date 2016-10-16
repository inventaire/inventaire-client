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

  initWorksCollections: (worksUris)->
    @works =
      books: new Works null, { uris: worksUris.books.map(getUri) }
      articles: new Works null, { uris: worksUris.articles.map(getUri) }

getUri = _.property 'uri'
