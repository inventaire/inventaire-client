import { propertiesPerType } from '#entities/lib/editor/properties_per_type'
import { without } from 'underscore'
import { typeHasName } from '#entities/lib/types/entities_types'
import { i18n } from '#user/lib/i18n'
import wdLang from 'wikidata-lang'
import preq from '#lib/preq'
import assert_ from '#lib/assert_types'
import properties from '#entities/lib/properties'

export function getMissingRequiredProperties ({ entity, requiredProperties, requiresLabel }) {
  const { type } = entity
  assert_.string(type)
  const missingRequiredProperties = []
  if (requiresLabel) {
    if (Object.keys(entity.labels).length <= 0) {
      if (typeHasName(type)) {
        missingRequiredProperties.push(i18n('name'))
      } else {
        missingRequiredProperties.push(i18n('title'))
      }
    }
  }
  for (const property of requiredProperties) {
    const propertyClaims = _.compact(entity.claims[property])
    if (propertyClaims.length <= 0) {
      const labelKey = propertiesPerType[type][property].customLabel || property
      missingRequiredProperties.push(i18n(labelKey))
    }
  }
  return missingRequiredProperties
}

export async function createEditionAndWorkFromEntry ({ edition, work }) {
  const title = edition.claims['wdt:P1476'][0]
  const titleLang = edition.claims['wdt:P407'][0]
  const workLabelLangCode = wdLang.byWdId[titleLang]?.code || 'en'
  work.labels = { [workLabelLangCode]: title }
  const entry = {
    edition,
    works: [ work ]
  }
  const { entries } = await preq.post(app.API.entities.resolve, {
    entries: [ entry ],
    update: true,
    create: true,
    enrich: true
  })
  const { uri } = entries[0].edition
  return uri
}

const propertiesShortlists = {
  human: [ 'wdt:P1412' ],
  work: [ 'wdt:P50' ],
  serie: [ 'wdt:P50' ],
  edition: [ 'wdt:P629', 'wdt:P1476', 'wdt:P1680', 'wdt:P123', 'invp:P2', 'wdt:P407', 'wdt:P577' ],
  publisher: [ 'wdt:P856', 'wdt:P112', 'wdt:P571', 'wdt:P576' ],
  collection: [ 'wdt:P1476', 'wdt:P123', 'wdt:P856' ]
}

export const getPropertiesShortlist = function (type, claims) {
  const typeShortlist = propertiesShortlists[type]
  if (typeShortlist == null) return null

  const claimsProperties = Object.keys(claims).filter(nonFixedEditor)
  let propertiesShortlist = propertiesShortlists[type].concat(claimsProperties)
  // If a serie was passed in the claims, invite to add an ordinal
  if (claimsProperties.includes('wdt:P179')) propertiesShortlist.push('wdt:P1545')
  propertiesShortlist = filterPerRole(propertiesShortlist)
  return propertiesShortlist
}

const dataadminOnlyShortlistedProperties = [
  'wdt:P31'
]

const filterPerRole = propertiesShortlist => {
  if (!propertiesShortlist) return
  if (app.user.hasDataadminAccess) return propertiesShortlist
  else return without(propertiesShortlist, ...dataadminOnlyShortlistedProperties)
}

const nonFixedEditor = function (prop) {
  // Testing properties[prop] existance as some properties don't
  // have an editor. Ex: wdt:P31
  const editorType = properties[prop]?.editorType
  if (!editorType) return false

  // Filter-out fixed editor: 'fixed-entity', 'fixed-string'
  if (editorType.split('-')[0] === 'fixed') return false

  return true
}
