InvEntity = require '../models/inv_entity'
error_ = require 'lib/error'

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
    return _.preq.resolve []

createBook = (title, authors, authorsNames, lang)->
  _.types arguments, ['string', 'array', 'array|null', 'string']

  labels = {}
  labels[lang] = title

  createAuthors authorsNames, lang
  .then (createdAuthors)->
    createdAuthorsUris = createdAuthors.map _.property('id')
    claims =
      # instance of (P31) -> book (Q571)
      'wdt:P31': ['wd:Q571']
      P50: authors.concat createdAuthorsUris

    createEntity labels, claims

createBookEdition = (title, authors, isbn, lang)->
  _.types arguments, ['string', 'array', 'string', 'string']
  createBook title, authors
  .then (entity)->
    claims =
      # instance of (P31) -> edition (Q3331189)
      'wdt:P31': ['wd:Q3331189']
      # edition or translation of (P629) -> created book
      'wdt:P629': [entity.get('uri')]

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
  app.entities.data.inv.local.post
    labels: labels
    claims: claims
  .then (entityData)-> new InvEntity entityData

module.exports =
  book: createBook
  bookEdition: createBookEdition
  author: createAuthor
  byProperty: byProperty
