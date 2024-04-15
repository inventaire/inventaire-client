import { without } from 'underscore'
import { inverseLabels } from '#entities/components/lib/claims_helpers'
import type { EntityType, PropertyUri } from '#server/types/entity'
import { i18n } from '#user/lib/i18n'

export function getRelativeEntitiesListLabel ({ property, entity }) {
  const label = inverseLabels[property]
  if (label) return i18n(label, { name: entity.label })
}

export function getRelativeEntitiesProperties (type: EntityType, mainProperty?: PropertyUri) {
  // TODO: add genre relatives
  let properties = relativeEntitiesPropertiesByType[type]
  // Omit the property already displayed in the entity browser of a claim layout.
  if (mainProperty) properties = without(properties, mainProperty)
  return properties || []
}

export const relativeEntitiesPropertiesByType = {
  work: [
    'wdt:P144', // based on
    'wdt:P941', // inspired by
    'wdt:P921', // main subject
    'wdt:P2675', // reply to
  ],
  subject: [
    'wdt:P135', // movement
    'wdt:P144', // based on
    'wdt:P840', // narrative location
    'wdt:P921', // main subject
    'wdt:P941', // inspired by
    'wdt:P1433', // published in
    'wdt:P69', // educated at
  ],
  human: [
    'wdt:P655', // translator
    'wdt:P737', // influenced by
    'wdt:P921', // main subject
  ],
}
