import assert_ from 'lib/assert_types'
import log_ from 'lib/loggers'
import Entity from '../models/entity'
import error_ from 'lib/error'
import { getIsbnData } from 'lib/isbn'
import createEntity from './create_entity'
import { addModel as addEntityModel } from 'modules/entities/lib/entities_models_index'
import graphRelationsProperties from './graph_relations_properties'
import getOriginalLang from 'modules/entities/lib/get_original_lang'
import { tap } from 'lib/promises'

const createWorkEdition = async function (workEntity, isbn) {
  assert_.types(arguments, [ 'object', 'string' ])

  return getIsbnData(isbn)
  .then(isbnData => {
    let { title, groupLang: editionLang } = isbnData
    log_.info(title, 'title from isbn data')
    if (!title) title = getTitleFromWork(workEntity, editionLang)
    log_.info(title, 'title after work suggestion')

    if (title == null) throw error_.new('no title could be found', isbn)

    const claims = {
      // instance of (P31) -> edition (Q3331189)
      'wdt:P31': [ 'wd:Q3331189' ],
      // isbn 13 (isbn 10 - if it exist - will be added by the server)
      'wdt:P212': [ isbnData.isbn13h ],
      // edition or translation of (P629) -> created book
      'wdt:P629': [ workEntity.get('uri') ],
      'wdt:P1476': [ title ]
    }

    if (isbnData.image != null) {
      claims['invp:P2'] = [ isbnData.image ]
    }

    return createAndGetEntity({ labels: {}, claims })
    .then(editionEntity => {
      // If work editions have been fetched, add it to the list
      workEntity.editions?.add(editionEntity)
      workEntity.push('claims.wdt:P747', editionEntity.get('uri'))
      return editionEntity
    })
  })
}

const getTitleFromWork = function (workEntity, editionLang) {
  const inEditionLang = workEntity.get(`labels.${editionLang}`)
  if (inEditionLang != null) return inEditionLang

  const inUserLang = workEntity.get(`labels.${app.user.lang}`)
  if (inUserLang != null) return inUserLang

  const originalLang = getOriginalLang(workEntity.get('claims'))
  const inWorkOriginalLang = workEntity.get(`labels.${originalLang}`)
  if (inWorkOriginalLang != null) return inWorkOriginalLang

  const inEnglish = workEntity.get('labels.en')
  if (inEnglish != null) return inEnglish

  return workEntity.get('labels')[0]
}

const byProperty = async function (options) {
  let { property, name, relationEntity, createOnWikidata, lang } = options
  if (!lang) lang = app.user.lang

  const wdtP31 = subjectEntityP31ByProperty[property]
  if (wdtP31 == null) {
    throw error_.new('no entity creation function associated to this property', options)
  }

  const claims = { 'wdt:P31': [ wdtP31 ] }

  let labels
  if (property === 'wdt:P195') {
    labels = {}
    claims['wdt:P1476'] = [ name ]
  } else {
    labels = { [lang]: name }
  }

  if (property === 'wdt:P179') {
    claims['wdt:P50'] = relationEntity.get('claims.wdt:P50')
  }

  if (property === 'wdt:P195') {
    claims['wdt:P123'] = relationEntity.get('claims.wdt:P123')
    if (claims['wdt:P123'] == null) {
      throw error_.new('a publisher should be set before creating a collection', options)
    }
  }

  return createAndGetEntity({ labels, claims, createOnWikidata })
}

const subjectEntityP31ByProperty = {
  // human
  'wdt:P50': 'wd:Q5',
  // publisher
  'wdt:P123': 'wd:Q2085381',
  // serie
  'wdt:P179': 'wd:Q277759',
  // work
  'wdt:P629': 'wd:Q47461344',
  'wdt:P655': 'wd:Q5',
  'wdt:P2679': 'wd:Q5',
  'wdt:P2680': 'wd:Q5',
  // collection
  'wdt:P195': 'wd:Q20655472'
}

const createAndGetEntity = function (params) {
  const { claims } = params
  return createEntity(params)
  .then(tap(triggerEntityGraphChangesEvents(claims)))
  .then(entityData => new Entity(entityData))
  // Update the local cache
  .then(tap(addEntityModel))
}

const triggerEntityGraphChangesEvents = claims => function () {
  for (const prop in claims) {
    const values = claims[prop]
    if (graphRelationsProperties.includes(prop)) {
      // Signal to the entity that it was affected by another entity's change
      // so that it refreshes it's graph data next time
      app.execute('invalidate:entities:graph', values)
    }
  }
}

export { createAndGetEntity as create, createWorkEdition, byProperty }
