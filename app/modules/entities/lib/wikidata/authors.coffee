wd_ = require 'lib/wikimedia/wikidata'

module.exports =
  fetchAuthorsWorks: (authorModel, refresh)->
    fetchAuthorsWorksIds authorModel, refresh
    .then fetchAuthorsWorksEntities.bind(null, authorModel, refresh)
    .then parseEntities
    .catch _.Error('wdAuthors_.fetchAuthorsWorks')

fetchAuthorsWorksIds = (authorModel, refresh)->
  if (not refresh) and authorModel.get('reverseClaims')?['wdt:P50']?
    return _.preq.resolved

  wd_.queryAuthorWorks authorModel.id, refresh
  .then _.Log('worksIds')
  .then authorModel.save.bind(authorModel, 'reverseClaims.wdt:P50')
  .catch _.Error('fetchAuthorsWorksIds err')

fetchAuthorsWorksEntities = (authorModel, refresh)->
  authorsWorks = authorModel.get 'reverseClaims.wdt:P50'
  _.log authorsWorks, 'authorsWorks'
  unless authorsWorks?.length > 0 then return _.preq.resolved

  # only fetching the 50 first entities to avoid querying entities
  # wikidata api won't return anyway due to API limits
  # TODO: implement pagination/continue
  authorsWorks = authorsWorks[0..49]
  return app.request 'get:entities:models', 'wd', authorsWorks, refresh

parseEntities = (entities)->
  # Compaction needed in case entities are missing
  # (typically because of API limits)
  entities = _.compact entities
  books = []
  articles = []
  for entity in entities
    switch wd_.type entity
      when 'book' then books.push entity
      when 'article' then articles.push entity

  return { books, articles }
