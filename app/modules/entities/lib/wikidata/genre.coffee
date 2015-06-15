wd_ = require 'lib/wikidata'

module.exports = wdGenre_ = {}

wdGenre_.fetchBooksAndAuthors = (genreModel)->
  wdGenre_.fetchBooksAndAuthorsIds(genreModel)
  .then wdGenre_.fetchBooksAndAuthorsEntities.bind(null, genreModel)
  .catch _.Error('wdGenre_.fetchBooksAndAuthors')


wdGenre_.fetchBooksAndAuthorsIds = (genreModel)->
  if genreModel.get('reverseClaims')?.P136? then return _.preq.resolve()

  numericId = wd_.getNumericId genreModel.id
  _.preq.get wd_.API.wmflabs.claim(136, numericId)
  .then wd_.parsers.wmflabs.ids
  .then _.Log('books and authors ids')
  .then genreModel.save.bind(genreModel, 'reverseClaims.P136')
  .catch _.Error('wdGenre_.fetchBooksAndAuthorsIds')


wdGenre_.fetchBooksAndAuthorsEntities = (genreModel, limit=30, offset=0)->
  first = offset
  last = offset + limit
  range = genreModel.get('reverseClaims.P136')[first...last]

  unless range.length > 0 then return _.preq.resolve()

  return app.request 'get:entities:models', 'wd', range

# EXPECT books collection, authors collection, entities models
wdGenre_.spreadBooksAndAuthors = (books, authors, entities)->

  unless entities? then return _.warn 'no entities to spread'

  entities.forEach (entity)->
    switch wd_.type entity
      when 'book' then books.add entity
      when 'author' then authors.add entity
      else _.warn [entity, entity.get('label'), entity.get('claims.P31')], 'neither a book or an author'
