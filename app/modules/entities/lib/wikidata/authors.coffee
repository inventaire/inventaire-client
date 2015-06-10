wd_ = require 'lib/wikidata'

module.exports = wdAuthors_ = {}

wdAuthors_.fetchAuthorsBooks = (authorModel)->
  wdAuthors_.fetchAuthorsBooksIds(authorModel)
  .then wdAuthors_.fetchAuthorsBooksEntities.bind(null, authorModel)
  .catch _.Error('wdAuthors_.fetchAuthorsBooks')

wdAuthors_.fetchAuthorsBooksIds = (authorModel)->
  if authorModel.get('reverseClaims')?.P50? then return _.preq.resolve()

  numericId = wd_.getNumericId authorModel.id
  # TODO: also fetch aliased Properties, not only P50
  _.preq.get wd_.API.wmflabs.claim(50, numericId)
  .then wd_.parsers.wmflabs.ids
  .then _.Log('booksIds')
  .then authorModel.save.bind(authorModel, 'reverseClaims.P50')
  .catch _.Error('fetchAuthorsBooksIds err')

wdAuthors_.fetchAuthorsBooksEntities = (authorModel)->
  authorsBooks = authorModel.get 'reverseClaims.P50'
  _.log authorsBooks, 'authorsBooks?'
  unless authorsBooks.length > 0 then return _.preq.resolve()

  return app.request 'get:entities:models', 'wd', authorsBooks
