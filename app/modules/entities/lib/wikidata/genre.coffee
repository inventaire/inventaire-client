wd_ = require 'lib/wikidata'

module.exports = wdGenre_ = {}

wdGenre_.fetchBooksAndAuthors = (genreModel)->
  wdGenre_.fetchBooksAndAuthorsIds(genreModel)
  # forcing default argument to neutralize fetchBooksAndAuthorsIds returned value
  .then wdGenre_.fetchBooksAndAuthorsEntities.bind(null, genreModel, null, null)
  .catch _.ErrorRethrow('wdGenre_.fetchBooksAndAuthors')


wdGenre_.fetchBooksAndAuthorsIds = (genreModel)->
  reverseClaims = genreModel.get 'reverseClaims'
  if reverseClaims?
    { P135, P136 } = reverseClaims
    if P135? or P136? then return _.preq.resolved

  Promise.all [
    getClaimSubjects('P135', genreModel) #mouvement
    getClaimSubjects('P136', genreModel) #genre
  ]
  .then _.flatten
  .catch _.ErrorRethrow('wdGenre_.fetchBooksAndAuthorsIds')

getClaimSubjects = (P, genreModel)->
  Q = genreModel.id
  wd_.getClaimSubjects P, Q
  .then _.uniq
  .then genreModel.save.bind(genreModel, "reverseClaims.#{P}")

# setting default limit to 10 to avoid loading too many authors
# which will load all their books in return
wdGenre_.fetchBooksAndAuthorsEntities = (genreModel, limit=10, offset=0)->
  _.types [genreModel, limit, offset], ['object', 'number', 'number']
  ids = _.flatten genreModel.gets('reverseClaims.P135', 'reverseClaims.P136')
  first = offset
  last = offset + limit
  range = ids[first...last]

  unless range.length > 0
    _.warn 'no more ids: range is empty'
    return _.preq.resolved

  return app.request 'get:entities:models', 'wd', range

# EXPECT books collection, authors collection, entities models
wdGenre_.spreadBooksAndAuthors = (books, authors, entities)->

  unless entities? then return _.warn 'no entities to spread'

  for entity in entities
    switch wd_.type entity
      when 'book' then books.add entity
      when 'human' then authors.add entity
      else _.warn [entity, entity.get('label'), entity.get('claims.P31')], 'neither a book or a human'
