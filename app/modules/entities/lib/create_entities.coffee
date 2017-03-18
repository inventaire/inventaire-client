Entity = require '../models/entity'
error_ = require 'lib/error'
isbn_ = require 'lib/isbn'
createInvEntity = require './inv/create_inv_entity'
{ addModel:addEntityModel } = require 'modules/entities/lib/entities_models_index'

createAuthor = (name, lang)->
  _.types arguments, 'strings...'
  labels = {}
  labels[lang] = name
  # instance of (P31) -> human (Q5)
  claims = { 'wdt:P31': ['wd:Q5'] }
  return createEntity labels, claims

createAuthors = (authorsNames, lang)->
  _.types arguments, ['array|null', 'string']
  if authorsNames?.length > 0
    return Promise.all authorsNames.map (name)-> createAuthor name, lang
  else
    return _.preq.resolve []

createBook = (title, authors, authorsNames, lang)->
  _.types arguments, ['string', 'array', 'array|null', 'string']

  labels = {}
  labels[lang] = title

  createAuthors authorsNames, lang
  .then (createdAuthors)->
    createdAuthorsUris = createdAuthors.map _.property('id')
    claims =
      # instance of (P31) -> book (Q571)
      # TODO: support other work P31 values
      'wdt:P31': ['wd:Q571']
      P50: authors.concat createdAuthorsUris

    return createEntity labels, claims

createWorkEdition = (workEntity, isbn)->
  _.types arguments, ['object', 'string']

  isbn_.getIsbnData isbn
  .then (isbnData)->
    claims =
      # instance of (P31) -> edition (Q3331189)
      'wdt:P31': ['wd:Q3331189']
      # isbn 13 (isbn 10 will be added by the server)
      'wdt:P212': [ isbnData.isbn13h ]
      # edition or translation of (P629) -> created book
      'wdt:P629': [ workEntity.get('uri') ]

    if isbnData.image?
      claims['wdt:P18'] = [ isbnData.image ]

    return createEntity {}, claims
    .then (editionEntity)->
      workEntity.editions.add editionEntity
      workEntity.push 'claims.wdt:P747', editionEntity.get('uri')
      return editionEntity

byProperty = (options)->
  { property, textValue, lang } = options
  lang or= app.user.lang
  switch property
    when 'wdt:P50' then return createAuthor textValue, lang
    else
      message = "no entity creation function associated to this property"
      throw error_.new message, arguments

createEntity = (labels, claims)->
  _.types arguments, 'objects...'
  createInvEntity { labels, claims }
  .then (entityData)-> new Entity entityData
  # Update the local cache
  .tap addEntityModel

module.exports =
  create: createEntity
  book: createBook
  workEdition: createWorkEdition
  author: createAuthor
  byProperty: byProperty
