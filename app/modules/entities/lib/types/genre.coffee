entities_ = require '../entities'

module.exports = genre_ = {}

genre_.fetchBooksAndAuthors = (genreModel)->
  fetchBooksAndAuthorsUris genreModel
  # forcing default argument to neutralize fetchBooksAndAuthorsUris returned value
  .then fetchBooksAndAuthorsEntities.bind(null, genreModel, null, null)
  .catch _.ErrorRethrow('genre_.fetchBooksAndAuthors')

fetchBooksAndAuthorsUris = (genreModel)->
  reverseClaims = genreModel.get 'reverseClaims'
  if reverseClaims?
    { 'wdt:P135':P135, 'wdt:P136':P136 } = reverseClaims
    if P135? or P136? then return _.preq.resolved

  Promise.all [
    getReverseClaims('wdt:P135', genreModel) #mouvement
    getReverseClaims('wdt:P136', genreModel) #genre
  ]
  .then _.flatten
  .catch _.ErrorRethrow('fetchBooksAndAuthorsUris')

getReverseClaims = (prop, genreModel)->
  uri = genreModel.get 'uri'
  entities_.getReverseClaims prop, uri
  .then _.uniq
  .then genreModel.set.bind(genreModel, "reverseClaims.#{prop}")

# setting default limit to 10 to avoid loading too many authors
# which will load all their books in return
fetchBooksAndAuthorsEntities = (genreModel, limit=10, offset=0)->
  _.types [genreModel, limit, offset], ['object', 'number', 'number']
  uris = _.flatten genreModel.gets('reverseClaims.wdt:P135', 'reverseClaims.wdt:P136')
  first = offset
  last = offset + limit
  range = uris[first...last]

  _.log range, 'range'

  unless range.length > 0
    _.warn 'no more uris: range is empty'
    return _.preq.resolved

  return app.request 'get:entities:models', range

# EXPECT books collection, authors collection, entities models
genre_.spreadBooksAndAuthors = (books, authors, entities)->
  unless entities? then return _.warn 'no entities to spread'
  for entity in entities
    switch  entity.type
      when 'book' then books.add entity
      when 'human' then authors.add entity
      else
        context = [ entity, entity.get('label'), entity.get('claims.wdt:P31') ]
        _.warn context, 'neither a book or a human'
