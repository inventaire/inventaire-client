wd_ = require 'lib/wikidata'
aliases = sharedLib 'wikidata_aliases'

module.exports =
  fetchAuthorsWorks: (authorModel, refresh)->
    fetchAuthorsWorksIds authorModel, refresh
    .then fetchAuthorsWorksEntities.bind(null, authorModel, refresh)
    .then parseEntities
    .catch _.Error('wdAuthors_.fetchAuthorsWorks')

fetchAuthorsWorksIds = (authorModel, refresh)->
  if (not refresh) and authorModel.get('reverseClaims')?.P50?
    return _.preq.resolved

  wd_.queryAuthorWorks authorModel.id, refresh
  .then _.Log('worksIds')
  .then authorModel.save.bind(authorModel, 'reverseClaims.P50')
  .catch _.Error('fetchAuthorsWorksIds err')

fetchAuthorsWorksEntities = (authorModel, refresh)->
  authorsWorks = authorModel.get 'reverseClaims.P50'
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
  # Could be optimized with a unique loop dispatcher instead of two filters
  books: _.compact(entities).filter wd_.entityIsBook
  articles: _.compact(entities).filter wd_.entityIsArticle
