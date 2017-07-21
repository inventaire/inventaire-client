Entity = require '../models/entity'
error_ = require 'lib/error'
isbn_ = require 'lib/isbn'
createInvEntity = require './inv/create_inv_entity'
{ addModel:addEntityModel } = require 'modules/entities/lib/entities_models_index'
graphRelationsProperties = require './graph_relations_properties'
wd_ = require 'lib/wikimedia/wikidata'

createAuthor = (name, lang)->
  _.types arguments, 'strings...'
  labels = {}
  labels[lang] = name
  # instance of (P31) -> human (Q5)
  claims = { 'wdt:P31': [ 'wd:Q5' ] }
  return createEntity labels, claims

createAuthors = (authorsNames, lang)->
  _.types arguments, ['array|null', 'string']
  if authorsNames?.length > 0
    return Promise.all authorsNames.map (name)-> createAuthor name, lang
  else
    return _.preq.resolve []

# Droping the 's' in 'series' to mark the difference with the plural form
createSerie = (name, lang, wdtP50)->
  _.types arguments, [ 'string', 'string', 'array|undefined' ]
  labels = {}
  labels[lang] = name
  # instance of (P31) -> book series (Q277759)
  claims = { 'wdt:P31': [ 'wd:Q277759' ] }
  if _.isNonEmptyArray wdtP50 then claims['wdt:P50'] = wdtP50
  return createEntity labels, claims

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
    { title, groupLang:editionLang } = isbnData
    _.log title, 'title from isbn data'
    title or= getTitleFromWork workEntity, editionLang
    _.log title, 'title after work suggestion'

    unless title? then throw error_.new 'no title could be found', isbn

    claims =
      # instance of (P31) -> edition (Q3331189)
      'wdt:P31': [ 'wd:Q3331189' ]
      # isbn 13 (isbn 10 - if it exist - will be added by the server)
      'wdt:P212': [ isbnData.isbn13h ]
      # edition or translation of (P629) -> created book
      'wdt:P629': [ workEntity.get('uri') ]
      'wdt:P1476': [ title ]

    if isbnData.image?
      claims['wdt:P18'] = [ isbnData.image ]

    return createEntity {}, claims
    .then (editionEntity)->
      workEntity.editions.add editionEntity
      workEntity.push 'claims.wdt:P747', editionEntity.get('uri')
      return editionEntity

getTitleFromWork = (workEntity, editionLang)->
  inEditionLang = workEntity.get "labels.#{editionLang}"
  if inEditionLang? then return inEditionLang

  inUserLang = workEntity.get "labels.#{app.user.lang}"
  if inUserLang? then return inUserLang

  originalLang = wd_.getOriginalLang workEntity.get('claims')
  inWorkOriginalLang = workEntity.get "labels.#{originalLang}"
  if inWorkOriginalLang? then return inWorkOriginalLang

  inEnglish = workEntity.get 'labels.en'
  if inEnglish? then return inEnglish

  return workEntity.get('labels')[0]

byProperty = (options)->
  { property, textValue, relationEntity, lang } = options
  lang or= app.user.lang
  switch property
    when 'wdt:P50', 'wdt:P655', 'wdt:P2679', 'wdt:P2680'
      return createAuthor textValue, lang
    when 'wdt:P179'
      return createSerie textValue, lang, relationEntity.get('claims.wdt:P50')
    else
      message = "no entity creation function associated to this property"
      throw error_.new message, arguments

createEntity = (labels, claims)->
  _.types arguments, 'objects...'
  createInvEntity { labels, claims }
  .tap triggerEntityGraphChangesEvents(claims)
  .then (entityData)-> new Entity entityData
  # Update the local cache
  .tap addEntityModel

triggerEntityGraphChangesEvents = (claims)-> ()->
  for prop, values of claims
    if prop in graphRelationsProperties
      for value in values
        # Signal to the entity that it was affected by another entity's change
        # so that it refreshes it's graph data next time
        if _.isEntityUri(value) then app.vent.trigger "entity:graph:change:#{value}"

  return

module.exports =
  create: createEntity
  book: createBook
  workEdition: createWorkEdition
  author: createAuthor
  byProperty: byProperty
