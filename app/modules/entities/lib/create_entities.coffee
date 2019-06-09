Entity = require '../models/entity'
error_ = require 'lib/error'
isbn_ = require 'lib/isbn'
createInvEntity = require './inv/create_inv_entity'
{ addModel:addEntityModel } = require 'modules/entities/lib/entities_models_index'
graphRelationsProperties = require './graph_relations_properties'
getOriginalLang = require 'modules/entities/lib/get_original_lang'

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
    return Promise.resolve []

createWorkOrSerie = (wdtP31)-> (name, lang, wdtP50)->
  _.types arguments, [ 'string', 'string', 'array|undefined' ], 2
  labels = {}
  labels[lang] = name
  claims = { 'wdt:P31': [ wdtP31] }
  if _.isNonEmptyArray wdtP50 then claims['wdt:P50'] = wdtP50
  return createEntity labels, claims

createSerie = createWorkOrSerie 'wd:Q277759'
createWork = createWorkOrSerie 'wd:Q571'

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
      claims['invp:P2'] = [ isbnData.image ]

    return createEntity {}, claims
    .then (editionEntity)->
      # If work editions have been fetched, add it to the list
      workEntity.editions?.add editionEntity
      workEntity.push 'claims.wdt:P747', editionEntity.get('uri')
      return editionEntity

createPublisher = (name, lang)->
  _.types arguments, 'strings...'
  labels = {}
  labels[lang] = name
  # instance of (P31) -> publisher (Q2085381)
  claims = { 'wdt:P31': [ 'wd:Q2085381' ] }
  return createEntity labels, claims

getTitleFromWork = (workEntity, editionLang)->
  inEditionLang = workEntity.get "labels.#{editionLang}"
  if inEditionLang? then return inEditionLang

  inUserLang = workEntity.get "labels.#{app.user.lang}"
  if inUserLang? then return inUserLang

  originalLang = getOriginalLang workEntity.get('claims')
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
    when 'wdt:P629'
      return createWork textValue, lang
    when 'wdt:P179'
      return createSerie textValue, lang, relationEntity.get('claims.wdt:P50')
    when 'wdt:P123'
      return createPublisher textValue, lang
    else
      message = 'no entity creation function associated to this property'
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
        app.vent.trigger "entity:graph:change:#{value}"

  return

module.exports =
  create: createEntity
  workEdition: createWorkEdition
  byProperty: byProperty
