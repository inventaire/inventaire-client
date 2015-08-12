wd_ = require 'lib/wikidata'
aliases = sharedLib 'wikidata_aliases'

module.exports =
  fetchAuthorsBooks: (authorModel)->
    fetchAuthorsBooksIds(authorModel)
    .then fetchAuthorsBooksEntities.bind(null, authorModel)
    .then keepOnlyBooks
    .catch _.Error('wdAuthors_.fetchAuthorsBooks')

fetchAuthorsBooksIds = (authorModel)->
  if authorModel.get('reverseClaims')?.P50? then return _.preq.resolve()

  # TODO: also fetch aliased Properties, not only P50
  _.preq.get wdk.getReverseClaims('P50', authorModel.id)
  .then wdk.parse.wdq.entities
  .then _.Log('booksIds')
  .then authorModel.save.bind(authorModel, 'reverseClaims.P50')
  .catch _.Error('fetchAuthorsBooksIds err')

fetchAuthorsBooksEntities = (authorModel)->
  authorsBooks = authorModel.get 'reverseClaims.P50'
  _.log authorsBooks, 'authorsBooks?'
  unless authorsBooks?.length > 0 then return _.preq.resolve()

  return app.request 'get:entities:models', 'wd', authorsBooks

keepOnlyBooks = (entities)-> entities.filter wd_.entityIsBook
