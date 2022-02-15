import log_ from '#lib/loggers'
import Entity from '../models/entity.js'
import error_ from '#lib/error'
import { getIsbnData } from '#lib/isbn'
import createEntity from './create_entity.js'
import { addModel as addEntityModel } from '#entities/lib/entities_models_index'
import graphRelationsProperties from './graph_relations_properties.js'
import getOriginalLang from '#entities/lib/get_original_lang'
import { isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'

const getTitleFromWork = function ({ workLabels, workClaims, editionLang }) {
  const inEditionLang = workLabels[editionLang]
  if (inEditionLang != null) return inEditionLang

  const inUserLang = workLabels[app.user.lang]
  if (inUserLang != null) return inUserLang

  const originalLang = getOriginalLang(workClaims)
  const inWorkOriginalLang = workLabels[originalLang]
  if (inWorkOriginalLang != null) return inWorkOriginalLang

  const inEnglish = workLabels.en
  if (inEnglish != null) return inEnglish

  return Object.values(workLabels)[0]
}

export const createWorkEditionDraft = async function ({ workEntity, isbn, isbnData, editionClaims }) {
  const { labels: workLabels, claims: workClaims, uri: workUri } = workEntity
  const claims = _.extend(editionClaims, {
    // instance of (P31) -> edition (Q3331189)
    'wdt:P31': [ 'wd:Q3331189' ],
    // edition or translation of (P629) -> created book
    'wdt:P629': [ workUri ],
  })
  let title, editionLang
  if (isbn && !isbnData) isbnData = await getIsbnData(isbn)
  if (isbnData) {
    editionLang = isbnData.groupLang
    title = isbnData.title
    log_.info(title, 'title from isbn data')
    log_.info(title, 'title after work suggestion')

    const { isbn13h } = isbnData

    // isbn 13 (isbn 10 - if it exist - will be added by the server)
    claims['wdt:P212'] = [ isbn13h ]

    if (isbnData.image != null) {
      claims['invp:P2'] = [ isbnData.image ]
    }
  }
  if (!title) title = getTitleFromWork(workLabels, workClaims, editionLang)
  if (title == null) throw error_.new('no title could be found', workEntity)
  claims['wdt:P1476'] = [ title ]
  return { labels: {}, claims }
}

export const createByProperty = async function (options) {
  let { property, name, relationSubjectEntity, createOnWikidata, lang } = options
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
    claims['wdt:P50'] = relationSubjectEntity.claims['wdt:P50']
  }

  if (property === 'wdt:P195') {
    claims['wdt:P123'] = relationSubjectEntity.claims['wdt:P123']
    if (claims['wdt:P123'] == null) {
      throw error_.new('a publisher should be set before creating a collection', options)
    }
  }

  return createAndGetEntityModel({ labels, claims, createOnWikidata })
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

export async function createAndGetEntityModel (params) {
  const { claims } = params
  cleanupClaims(claims)
  const entityData = await createEntity(params)
  triggerEntityGraphChangesEvents(claims)
  const model = new Entity(entityData)
  // Update the local cache
  addEntityModel(model)
  return model
}

function cleanupClaims (claims) {
  for (const [ property, propertyClaims ] of Object.entries(claims)) {
    claims[property] = propertyClaims.filter(isNonEmptyClaimValue)
  }
}

export async function createAndGetEntity (params) {
  const model = await createAndGetEntityModel(params)
  return model.toJSON()
}

const triggerEntityGraphChangesEvents = claims => {
  for (const prop in claims) {
    const values = claims[prop]
    if (graphRelationsProperties.includes(prop)) {
      // Signal to the entity that it was affected by another entity's change
      // so that it refreshes it's graph data next time
      app.execute('invalidate:entities:graph', values)
    }
  }
}
