wd_ = require 'lib/wikidata'
aliases = sharedLib 'wikidata_aliases'

module.exports =
  fetchAuthorsBooks: (authorModel, refresh)->
    fetchAuthorsBooksIds authorModel, refresh
    .then fetchAuthorsBooksEntities.bind(null, authorModel, refresh)
    .then keepOnlyBooks
    .catch _.Error('wdAuthors_.fetchAuthorsBooks')

fetchAuthorsBooksIds = (authorModel, refresh)->
  if (not refresh) and authorModel.get('reverseClaims')?.P50?
    return _.preq.resolve()

  # TODO: also fetch aliased Properties, not only P50
  wd_.getReverseClaims 'P50', authorModel.id, refresh
  .then _.Log('booksIds')
  .then authorModel.save.bind(authorModel, 'reverseClaims.P50')
  .catch _.Error('fetchAuthorsBooksIds err')

fetchAuthorsBooksEntities = (authorModel, refresh)->
  authorsBooks = authorModel.get 'reverseClaims.P50'
  _.log authorsBooks, 'authorsBooks'
  unless authorsBooks?.length > 0 then return _.preq.resolve()

  # only fetching the 50 first entities to avoid querying entities
  # wikidata api won't return anyway due to API limits
  # TODO: implement pagination/continue
  authorsBooks = authorsBooks[0..49]
  return app.request 'get:entities:models', 'wd', authorsBooks, refresh

keepOnlyBooks = (entities)->
  # compaction needed in case entities are missing
  # (typically because of API limits)
  _.compact(entities).filter wd_.entityIsBook
