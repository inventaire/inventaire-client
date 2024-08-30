import { compact, pick, uniq } from 'underscore'
import wdLang from 'wikidata-lang'
import { API } from '#app/api/api'
import assert_ from '#app/lib/assert_types'
import { isNonEmptyArray } from '#app/lib/boolean_tests'
import preq from '#app/lib/preq'
import type { EntityDraft } from '#app/types/entity'
import { getWorkPreferredAuthorRolesProperties } from '#entities/lib/editor/properties_per_subtype'
import { priorityPropertiesPerType, propertiesPerType } from '#entities/lib/editor/properties_per_type'
import { propertiesEditorsConfigs } from '#entities/lib/properties'
import { typeHasName } from '#entities/lib/types/entities_types'
import type { PropertyUri, SerializedEntity } from '#server/types/entity'
import { i18n } from '#user/lib/i18n'

interface GetMissingRequiredPropertiesParams {
  entity: SerializedEntity | EntityDraft
  requiredProperties: PropertyUri[]
  requiresLabel?: boolean
}
export function getMissingRequiredProperties ({ entity, requiredProperties, requiresLabel }: GetMissingRequiredPropertiesParams) {
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
    const propertyClaims = compact(entity.claims[property])
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
    works: [ work ],
  }
  const { entries } = await preq.post(API.entities.resolve, {
    entries: [ entry ],
    update: true,
    create: true,
    enrich: true,
  })
  const { uri } = entries[0].edition
  return uri
}

export function getPropertiesShortlist (entity) {
  const { type, claims } = entity
  const typeShortlist = priorityPropertiesPerType[type]

  const claimsProperties = Object.keys(claims)
    .filter(isShortlistableProperty({ claims, type }))

  const propertiesShortlist = uniq(typeShortlist.concat(claimsProperties))
  // If a serie was passed in the claims, invite to add an ordinal
  if (claimsProperties.includes('wdt:P179')) propertiesShortlist.push('wdt:P1545')
  const authorProperties = getWorkPreferredAuthorRolesProperties(entity)
  return uniq(propertiesShortlist.flatMap(property => {
    if (property === 'wdt:P50') return authorProperties
    else return [ property ]
  }))
}

const isShortlistableProperty = ({ claims, type }) => property => {
  const values = claims[property]
  if (!isNonEmptyArray(values)) return false

  // Some properties might not have an editor
  const datatype = propertiesEditorsConfigs[property]?.datatype
  if (!datatype) return false

  if (propertiesPerType[type][property] == null) return false

  // Filter-out fixed editor: 'fixed-entity', 'fixed-string'
  if (datatype.split('-')[0] === 'fixed') return false

  return true
}

export function removeNonTypeProperties (claims, typeProperties) {
  const typePropertiesIds = Object.keys(typeProperties)
  return pick(claims, typePropertiesIds)
}
