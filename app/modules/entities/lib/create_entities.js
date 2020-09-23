Entity = require '../models/entity'
error_ = require 'lib/error'
isbn_ = require 'lib/isbn'
createEntity = require './create_entity'
{ addModel:addEntityModel } = require 'modules/entities/lib/entities_models_index'
graphRelationsProperties = require './graph_relations_properties'
getOriginalLang = require 'modules/entities/lib/get_original_lang'

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

    return createAndGetEntity { labels: {}, claims }
    .then (editionEntity)->
      # If work editions have been fetched, add it to the list
      workEntity.editions?.add editionEntity
      workEntity.push 'claims.wdt:P747', editionEntity.get('uri')
      return editionEntity

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
  { property, name, relationEntity, createOnWikidata, lang } = options
  lang or= app.user.lang

  wdtP31 = subjectEntityP31ByProperty[property]
  unless wdtP31?
    throw error_.new 'no entity creation function associated to this property', options

  labels = { "#{lang}": name }
  claims = { 'wdt:P31': [ wdtP31 ] }

  if property is 'wdt:P179'
    claims['wdt:P50'] = relationEntity.get 'claims.wdt:P50'

  return createAndGetEntity { labels, claims, createOnWikidata }

subjectEntityP31ByProperty =
  # human
  'wdt:P50': 'wd:Q5'
  # publisher
  'wdt:P123': 'wd:Q2085381'
  # serie
  'wdt:P179': 'wd:Q277759'
  # work
  'wdt:P629': 'wd:Q47461344'
  'wdt:P655': 'wd:Q5'
  'wdt:P2679': 'wd:Q5'
  'wdt:P2680': 'wd:Q5'

createAndGetEntity = (params)->
  { claims } = params
  createEntity params
  .tap triggerEntityGraphChangesEvents(claims)
  .then (entityData)-> new Entity entityData
  # Update the local cache
  .tap addEntityModel

triggerEntityGraphChangesEvents = (claims)-> ()->
  for prop, values of claims
    if prop in graphRelationsProperties
      # Signal to the entity that it was affected by another entity's change
      # so that it refreshes it's graph data next time
      app.execute 'invalidate:entities:graph', values

  return

module.exports =
  create: createAndGetEntity
  workEdition: createWorkEdition
  byProperty: byProperty
