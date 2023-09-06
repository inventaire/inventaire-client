import { propertiesPerType } from '#entities/lib/editor/properties_per_type'
import { pick, uniq, without } from 'underscore'
import { typeHasName } from '#entities/lib/types/entities_types'
import { i18n } from '#user/lib/i18n'
import wdLang from 'wikidata-lang'
import preq from '#lib/preq'
import assert_ from '#lib/assert_types'
import { propertiesEditorsConfigs } from '#entities/lib/properties'
import { isNonEmptyArray } from '#lib/boolean_tests'
import { getWorkPreferredAuthorRolesProperties } from '#entities/lib/editor/properties_per_subtype'

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
  work: [ 'wdt:P31', 'wdt:P50' ],
  serie: [ 'wdt:P31', 'wdt:P50' ],
  edition: [ 'wdt:P629', 'wdt:P1476', 'wdt:P1680', 'wdt:P123', 'invp:P2', 'wdt:P407', 'wdt:P577' ],
  publisher: [ 'wdt:P856', 'wdt:P112', 'wdt:P571', 'wdt:P576' ],
  collection: [ 'wdt:P1476', 'wdt:P123', 'wdt:P856' ]
}

export function getPropertiesShortlist (entity) {
  const { type, claims } = entity
  const typeShortlist = propertiesShortlists[type]

  const claimsProperties = Object.keys(claims)
    .filter(isShortlistableProperty({ claims, type }))

  let propertiesShortlist = uniq(typeShortlist.concat(claimsProperties))
  // If a serie was passed in the claims, invite to add an ordinal
  if (claimsProperties.includes('wdt:P179')) propertiesShortlist.push('wdt:P1545')
  propertiesShortlist = filterPerUserRole(propertiesShortlist)
  const authorProperties = getWorkPreferredAuthorRolesProperties(entity)
  return propertiesShortlist.flatMap(property => {
    if (property === 'wdt:P50') return authorProperties
    else return [ property ]
  })
}

const dataadminOnlyShortlistedProperties = [
  'wdt:P31'
]

const filterPerUserRole = propertiesShortlist => {
  if (!propertiesShortlist) return
  if (app.user.hasDataadminAccess) return propertiesShortlist
  else return without(propertiesShortlist, ...dataadminOnlyShortlistedProperties)
}

const isShortlistableProperty = ({ claims, type }) => property => {
  const values = claims[property]
  if (!isNonEmptyArray(values)) return false

  // Some properties might not have an editor
  const editorType = propertiesEditorsConfigs[property]?.editorType
  if (!editorType) return false

  if (propertiesPerType[type][property] == null) return false

  // Filter-out fixed editor: 'fixed-entity', 'fixed-string'
  if (editorType.split('-')[0] === 'fixed') return false

  return true
}

export function removeNonTypeProperties (claims, typeProperties) {
  const typePropertiesIds = Object.keys(typeProperties)
  return pick(claims, typePropertiesIds)
}
